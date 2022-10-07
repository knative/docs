# Function Event Sources

In the previous section, you created a basic function that could receive
and respond to HTTP requests. Now, let's create a new function that can respond
to CloudEvents that are sent by Knative Eventing resources.

In this tutorial, you will create a simple Knative event source to generate
CloudEvents, as well as other Knative Eventing resources. You'll learn more
about Knative Eventing [later on in this tutorial](./getting-started-eventing.md).

First, create and deploy the function.
## Create a CloudEvent Function

To create and deploy a CloudEvent function that echoes the CloudEvent it receives,
you can use the `create` and `deploy` commands.

Create the function by running the command:

=== "func"

    ```{ .console}
    func create -l go -t cloudevents echo
    ```

=== "kn func"

    ```{ .console }
    kn func create -l go -t cloudevents echo
    ```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Created go function in echo
    ```

And deploy the function with the `deploy` command from within the project directory:

=== "func"

    ```{ .console}
    cd echo
    func deploy -r <registry>
    ```

=== "kn func"

    ```{ .console }
    cd echo
    kn func deploy -r <registry>
    ```
!!! Success "Expected output"
    ```{ .console .no-copy }
        🙌 Function image built: <registry>/echo:latest
        ✅ Function deployed in namespace "default" and exposed at URL:
        http://echo.default.127.0.0.1.sslip.io
    ```

For many of the following commands, you will use the `kn` CLI. If you have followed
the [Quickstart](./quickstart-install.md) section of the tutorial, you should already
already have the `kn` CLI installed.

## Create a Broker

Next, we'll create a Broker to buffer events between the event source and the function.

Create a Broker named `default` by running the command:

```{ .console }
kn broker create default
```

!!! Success "Expected output"
    ```{ .console .no-copy }
      Broker 'default' successfully created in namespace 'default'.
    ```

## Create a PingSource

To ensure we get events quickly, we'll create a
[PingSource](https://knative.dev/docs/eventing/sources/ping-source/)
which generates an event every minute. Note that the PingSource uses
a `crontab`-type expression:


Create a PingSource named, `ping` by running the command:

```{ .console }
kn source ping create ping --sink broker:default --schedule="*/1 * * * *"
```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Ping source 'ping' created in namespace 'default'.
    ```

## Create a Trigger

Now that the Broker and PingSource are created, you can create a Trigger that
will forward all PingSource events to the function. In the following command,
the `--sink` flag specifies your function as the destination for the CloudEvents.

Create a Trigger named `ping-trigger` by running the command:

```{ .console }
kn trigger create ping-trigger --sink hello
```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Trigger 'ping-trigger' successfully created in namespace 'default'.
    ```

To see your function being invoked, you can use the `kubectl` CLI to watch the
logs of the function pod. Watch the logs of the function pod by running the command:

```{ .console }
kubectl logs -l function.knative.dev=true --tail=10 -f
```

It may take a moment for your function to be fully deployed. The above command uses
the `-f` flag to follow the logs, so you will see the logs as they are generated.
Type `Ctrl+C` to exit the command.

!!! Success "Expected output"
    ```{ .console .no-copy }
    Received event
    Context Attributes,
      specversion: 1.0
      type: dev.knative.sources.ping
      source: /apis/v1/namespaces/default/pingsources/ping
      id: d467df81-3296-48ed-bb1c-0662153f53b1
      time: 2022-09-23T14:25:00.344067423Z
    Extensions,
      knativearrivaltime: 2022-09-23T14:25:01.295357548Z
    ```

## Clean up

To clean up everything you created in this section of the tutorial, run the following commands:

```{ .console }
kn trigger delete ping-trigger
kn source ping delete ping
kn broker delete default
kn service delete echo
kn service delete hello
```

When you deploy a Function, it is deployed as a Knative Service.
Next up, we'll take a look at how to deploy a Knative Service with the `kn` CLI and a
pre-built container image, and we'll explore some of the features of Knative Services.
