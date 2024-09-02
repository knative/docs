# Building Stateful applications with Knative and Restate

Knative revolutionized developing and operating serverless applications on Kubernetes, but it is still quite challenging to build stateful applications on top of it.

For example, let's say you want to build an application that needs to persist some state.
In order to do so, you might need to connect your service to a database, and when doing so, you'll need to deal with retries, duplicate events, double writes, and all sort of other distributed systems issues.

As another example, let's assume you want to build a service orchestator that needs to invoke different services, and eventually compensate some operation if one of them fails.
Ideally, you just want to write some sequential code that executes one operation after another, and performs a rollback if one of them fails.
In practice though, this won't be so easy, because you'll need to solve problems such as retries when invoking downstream services, failures of the orchestator service, or even more tricky long waiting times when invoking downstream services.

What if you could embed the app state and execute complex services coordination all within your Knative services, without having to deal with any of those aforementioned issues?

## Enter Restate

[Restate](https://github.com/restatedev/restate/) is an open source Durable Execution Engine to build stateful serverless applications.
In other words, you build code that looks like usual RPC services, and the code is executed durably, that is the engine stores the execution progress.
After a crash, the engine transparently restores the application to the previous state and resumes the execution from the point where it left off.

Another aspect of recording the execution progress is that in case of a long waiting time, e.g. due to a service slow to respond, the engine automatically suspends the execution, to avoid wasting compute resources.
In practice this means that during "waiting time", the application can be scaled down to zero!

By using Restate and Knative together you can develop stateful entities, orchestrate microservices, implement saga patterns, deduplicate events, while being able to scale-to-zero when no work is required.
Restate will take care of the hard distributed systems problems such as state consistency, cross-service communication, failure recovery, and so on.

With Restate you build applications using one of the available Restate SDKs, and then deploy it as a serverless/stateless HTTP server, for example using Knative services.
Right now Restate supports Golang, Java, Kotlin, Typescript, Rust and Python.
To invoke your services, you send requests to Restate rather than to your service directly, such that Restate acts like a "proxy" between your clients and your services.

To deploy the Restate engine there are different strategies: you can deploy it as a stateful deployment on your k8s cluster, similarly to how you would deploy a database, or you can use Restate Cloud managed service.
For more info, check [How to deploy Restate](https://docs.restate.dev/deploy/overview).

## Signup flow example

To give you a glimpse of how it works, I'm gonna show you an example of how to build a signup flow using Knative and Restate together.
The example application is composed as follows:

* A user service, where we store the user information.
* A signup service, which encapsulates the flow to sign up a new user, send a confirmation email, and activate it afterwards.

### User service

Let's start with the user service.

To build it, we'll create a Restate _Virtual Object_, that is an abstraction to encapsulate a set of RPC handlers with a K/V store associated with it.
Virtual objects are addressable by a key, which you provide when invoking one of its handlers.
Moreover, Virtual Objects have an intrinsic lock per key, meaning Restate will make sure **at most one request** can run at the same time for a given key, and any additional request will be enqueued in a **per-key** queue.

Let's start by defining the handler to get the user data:

```golang
// Struct to encapsulate the user service logic
type userObject struct{}

// User struct definition, ser/deserializeable with json
type User struct {
	Name     string `json:"name"`
	Surname  string `json:"surname"`
	Password string `json:"password"`
}

func (t *userObject) Get(ctx restate.ObjectSharedContext) (User, error) {
	return restate.Get[User](ctx, "user")
}
```

Each Restate handler is called with a `Context`, an interface encapsulating the various features Restate exposes to developers.
This context is different depending on the type of handler.

In this case, we use `restate.Get`, which reads a value from the Restate's Virtual Object K/V store.

Then, we can define the handler to `Initialize` the user:

```golang
// Initialize will initialize the user object
func (t *userObject) Initialize(ctx restate.ObjectContext, user User) error {
	// Check if the user doesn't exist first
	usr, err := restate.Get[*User](ctx, "user")
	if err != nil {
		return err
	}
	if usr != nil {
		return restate.TerminalError(fmt.Errorf("the user was already initialized"))
	}

	// Store the user
	restate.Set(ctx, "user", user)

	// Store the unactivated status
	restate.Set(ctx, "activated", false)
	
	return nil
}
```

Similarly to `restate.Get`, with `restate.Set` we can write the Virtual Object K/V store.

Last, the handler to `Activate` a user after it has been initialized:

```golang
// Activate will signal the user is activated
func (t *userObject) Activate(ctx restate.ObjectContext) error {
	// Check if the user exists first
	usr, err := restate.Get[*User](ctx, "user")
	if err != nil {
		return err
	}
	if usr == nil {
		return restate.TerminalError(fmt.Errorf("the user doesn't exist"))
	}

	// Store the activated status
	restate.Set(ctx, "activated", false)

	return nil
}
```

We're now ready to implement the signup service.

### Signup service

The signup service has a single handler that orchestrates the signup:

```golang
func (t *signupService) Signup(ctx restate.ObjectSharedContext, newUser NewUser) (string, error) {
	// Initialize the newUser first
	user := User{
		Name:     newUser.Name,
		Surname:  newUser.Surname,
		Password: newUser.Password,
	}
	_, err := restate.Object[restate.Void](ctx, "User", newUser.Username, "Initialize").Request(user)
	if err != nil {
		return "", err
	}

	// Prepare an awakeable to await the email activation
	awakeable := restate.Awakeable[restate.Void](ctx)

	// Send the activation email
	_, err = restate.Run[restate.Void](ctx, func(ctx restate.RunContext) (restate.Void, error) {
		return restate.Void{}, sendEmail(newUser.Username, awakeable.Id())
	})
	if err != nil {
		return "", err
	}

	// Await the activation
	_, err = awakeable.Result()
	if err != nil {
		return "", err
	}

	// Activate the user
	_, err = restate.Object[restate.Void](ctx, "User", newUser.Username, "Activate").Request(user)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("The new user %s is signed up and activated", newUser.Username), nil
}
```

Using `restate.Call` we can invoke other Restate services.
These requests are guaranteed to be executed exactly once.

With `restate.Awakeable` we can await an arbitrary event happening.
You can complete requests simply [sending HTTP requests](https://docs.restate.dev/develop/ts/awakeables#completing-awakeables) to Restate providing the Awakeable id.
In our example, the email will embed a link containing the Awakeable id, which will be completed once the user clicks on the verification button.

With `restate.Run` we can execute any arbitrary piece of code and memoize the result, such that in case of a crash, Restate won't re-execute that chunk of code, but will load the stored result and use it for the subsequent operations.

### Start the HTTP service and deploy it with Knative

To expose the services using HTTP:

```golang
func main() {
	// Read PORT env injected by Knative Serving
	port := os.Getenv("PORT")
	if port == "" {
		port = "9080"
	}
	bindAddress := fmt.Sprintf(":%s", port)

	// Bind services to the Restate HTTP/2 server
	srv := server.NewRestate().
		Bind(restate.Reflect(&userObject{})).
		Bind(restate.Reflect(&signupService{}))

	// Start HTTP/2 server
	if err := srv.Start(context.Background(), bindAddress); err != nil {
		slog.Error("application exited unexpectedly", "err", err.Error())
		os.Exit(1)
	}
}
```

You can now build the container image using your tools, e.g. with `ko`:

```shell
$ ko build main.go -B
```

And deploy it with `kn`:

```shell
$ kn service create signup \
  --image $MY_IMAGE_REGISTRY/main.go \
  --port h2c:8080
```

Before sending requests, you need to tell Restate about your new service deployment:

```shell
$ restate deployments register http://signup.default.svc
```

And this is it! You're now ready to send requests:

```shell
$ curl http://localhost:8080/Signup/Signup --json '{"username": "slinkydeveloper", "name": "Francesco", "surname": "Guardiani", "password": "Pizza-without-pineapple"}'
```

Please note: some parts of the code example are omitted for brevity, check the [full example](TODO) for more details and how to run this locally with `kind`.

### We got your back

Let's assume for a second that the `sendEmail` function in the `Signup` flow fails the first time we try the signup, what would it happen?

Without Restate, you would need to retry executing `sendEmail` a couple of times in a loop.
But what if, while retrying to execute `sendEmail`, **the signup service crashes or goes away**?
In that case, you'll lose track of the signup progress, and next time the user presses F5, you'll need some logic to reconstruct the state of the previous signup and/or discard it.

With Restate, if `sendEmail` fails, it will be automatically retried, and all the operations that have been executed previously, in this case the call to the `User/Initialize` handler, won't be executed again, but their result values will simply be restored.

This is possible thanks to Restate's Durable Execution Engine, that records the progress of your application, and in case of a crash it restarts from the point where it was last interrupted.
Even more, Restate is able to suspend the execution when no progress can be made, e.g. in case of a long sleep, or when waiting a response from another service, all of that without splitting your business logic in a sequence of different handlers.
Yes, you got it right, **while waiting your Knative service can scale down to zero!**

## What's next

In this post we've looked at how to build a stateful entity and a simple orchestration flow using Restate and deploy it on Knative.

By combining Restate and Knative together you get the best of both worlds, as you can build serverless application with the ease of developing stateful applications.

With Restate and Knative together you can build much more: [workflows](https://docs.restate.dev/use-cases/workflows), [sagas](https://restate.dev/blog/graceful-cancellations-how-to-keep-your-application-and-workflow-state-consistent/), [stateful event processing](https://docs.restate.dev/use-cases/event-processing#stateful-event-processing-with-restate) (combining Knative Eventing too!) just to name few ideas.
Check out the Restate examples to get a grasp of what's possible to build: https://github.com/restatedev/examples