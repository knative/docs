A simple web app written in Go that you can use to test knative eventing. It shows how to consume a [CloudEvent](https://cloudevents.io/) in Knative eventing, and optionally how to respond back with another CloudEvent in the http response, using the [Go SDK for CloudEvents](https://github.com/cloudevents/sdk-go)

We will deploy the app as a [Kubernetes Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) along with a [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/).
However, you can also deploy the app as a [Knative Serving Service](../../../../serving/README.md).

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/eventing/samples/helloworld/helloworld-go
```

## Before you begin

- A Kubernetes cluster with [Knative Eventing](../../../getting-started.md#installing-knative-eventing) installed.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new file named `helloworld.go` and paste the following code. This
   code creates a basic web server which listens on port 8080:

   ```go
    package main

    import (
      "context"
      "fmt"
      "log"
      "net/http"
      "os"

      cloudevents "github.com/cloudevents/sdk-go"
      "github.com/google/uuid"
    )

    type eventData struct {
      Message string `json:"message,omitempty,string"`
    }

    func receive(ctx context.Context, event cloudevents.Event, response *cloudevents.EventResponse) error {
      // Here is where your code to process the event will go.
      // In this example we will log the event msg
      log.Printf("Event Context: %+v\n", event.Context)
      data := &HelloWorld{}
      if err := event.DataAs(data); err != nil {
        log.Printf("Error while extracting cloudevent Data: %s\n", err.Error())
        return err
      }
      log.Printf("Hello World Message %q", data.Msg)

      // Respond with another event (optional)
      // This is optional and is intended to show how to respond back with another event after processing.
      // The response will go back into the knative eventing system just like any other event
      newEvent := cloudevents.NewEvent()
      newEvent.SetID(uuid.New().String())
      newEvent.SetSource("knative/eventing/samples/hello-world")
      newEvent.SetType("dev.knative.samples.hifromknative")
      newEvent.SetData(HiFromKnative{Msg: "Hi from Knative!"})
      response.RespondWith(200, &newEvent)

      log.Printf("Responded with event %v", newEvent)

      return nil
    }

    func handler(w http.ResponseWriter, r *http.Request) {
      log.Print("Hello world received a request.")
      target := os.Getenv("TARGET")
      if target == "" {
        target = "World"
      }
      fmt.Fprintf(w, "Hello %s!\n", target)
    }

    func main() {
      log.Print("Hello world sample started.")
      c, err := cloudevents.NewDefaultClient()
      if err != nil {
        log.Fatalf("failed to create client, %v", err)
      }
      log.Fatal(c.StartReceiver(context.Background(), receive))
    }
   ```
1. Create a new file named `eventschemas.go` and paste the following code. This defines the data schema of the CloudEvents.

   ```go
    package main

    // HelloWorld defines the Data of CloudEvent with type=dev.knative.samples.helloworld
    type HelloWorld struct {
      // Msg holds the message from the event
      Msg string `json:"msg,omitempty,string"`
    }

    // HiFromKnative defines the Data of CloudEvent with type=dev.knative.samples.hifromknative
    type HiFromKnative struct {
      // Msg holds the message from the event
      Msg string `json:"msg,omitempty,string"`
    }
   ```
  
1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Go app, see
   [Deploying Go servers with Docker](https://blog.golang.org/docker).

   ```docker
   # Use the offical Golang image to create a build artifact.
   # This is based on Debian and sets the GOPATH to /go.
   # https://hub.docker.com/_/golang
   FROM golang:1.12 as builder

   # Copy local code to the container image.
   WORKDIR /go/src/github.com/knative/docs/helloworld
   COPY . .

   # Build the command inside the container.
   # (You may fetch or manage dependencies here,
   # either manually or with a tool like "godep".)
   RUN CGO_ENABLED=0 GOOS=linux go build -v -o helloworld

   # Use a Docker multi-stage build to create a lean production image.
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM alpine
   RUN apk add --no-cache ca-certificates

   # Copy the binary to the production image from the builder stage.
   COPY --from=builder /go/src/github.com/knative/docs/helloworld/helloworld /helloworld

   # Run the web service on container startup.
   CMD ["/helloworld"]
   ```

1. Create a new file, `sample-app.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   # Namespace for sample application with eventing enabled
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-samples
      labels:
          knative-eventing-injection: enabled
    ---
    # Helloworld-go app deploment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: helloworld-go
    spec:
      replicas: 1
      selector:
        matchLabels: &labels
          app: helloworld-go
      template:
        metadata:
          labels: *labels
        spec:
          containers:
            - name: helloworld-go
              image: docker.io/{username}/helloworld-go

    ---

    # Service that exposes helloworld-go app.
    # This will be the subscriber for the Trigger
      kind: Service
      apiVersion: v1
      metadata:
        name: helloworld-go
      spec:
        selector:
          app: helloworld-go
        ports:
        - protocol: TCP
          port: 80
          targetPort: 8080
    ---
    # Knative Eventing Trigger to trigger the helloworld-go service
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: helloworld-go
      namespace: knative-samples
    spec:
      broker: default
      filter:
        attributes:
          type: dev.knative.samples.helloworld
          source: dev.knative.samples/helloworldsource
      subscriber:
        ref:
          apiVersion: v1
          kind: Service
          name: helloworld-go
    ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-go .

   # Push the container to docker registry
   docker push {username}/helloworld-go
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the sample application into your cluster. Ensure that the container image value
   in `sample-app.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename sample-app.yaml
   ```
    1.  Above command created a namespace `knative-samples` and labelled it with `knative-eventing-injection=enabled`, to enable eventing in the namespace. Verify using the following command:
        ```shell
        kubectl get ns knative-samples --show-labels
        ```
    1. It deployed the helloworld-go app as a K8s Deployment and created a K8s service names helloworld-go. Verify using the following command.
        ```shell
        kubectl --namespace knative-samples get deployments helloworld-go
        
        kubectl --namespace knative-samples get svc helloworld-go
        ```
    1. It created a Knative Eventing Trigger to route certain events to the helloworld-go application. Make sure that Ready=true
        ```shell
        kubectl --namespace knative-samples get trigger helloworld-go 
        ```
## Send and verify CloudEvents
Once you have deployed the application and verified that the namespace, sample application and trigger are ready, let's send a CloudEvent.

### Send CloudEvent to the Broker
We can send an http request directly to the [Broker](../../../broker-trigger.md) with correct CloudEvent headers set.

   1. Deploy a curl pod and SSH into it
      ```shell
      kubectl --namespace knative-samples run curl --image=radial/busyboxplus:curl -it
      ```
  1. Run the following in the SSH terminal
      ```shell
      curl -v "default-broker.knative-samples.svc.cluster.local" \
      -X POST \
      -H "Ce-Id: 536808d3-88be-4077-9d7a-a3f162705f79" \
      -H "Ce-specversion: 0.3" \
      -H "Ce-Type: dev.knative.samples.helloworld" \
      -H "Ce-Source: dev.knative.samples/helloworldsource" \
      -H "Content-Type: application/json" \
      -d '{"msg":"Hello World from the curl pod."}'


      exit
      ``` 
### Verify that event is received by helloworld-go app
Helloworld-go app logs the context and the msg of the above event, and replies back with another event. 
  1. Display helloworld-go app logs
      ```shell
      kubectl --namespace knative-samples logs -l app=helloworld-go --tail=50
      ```
      You should see something similar to:
      ```shell
      Event received. Context: Context Attributes,
        specversion: 0.3
        type: dev.knative.samples.helloworld
        source: dev.knative.samples/helloworldsource
        id: 536808d3-88be-4077-9d7a-a3f162705f79
        time: 2019-10-04T22:35:26.05871736Z
        datacontenttype: application/json
      Extensions,
        knativearrivaltime: 2019-10-04T22:35:26Z
        knativehistory: default-kn2-trigger-kn-channel.knative-samples.svc.cluster.local
        traceparent: 00-971d4644229653483d38c46e92a959c7-92c66312e4bb39be-00

      Hello World Message "Hello World from the curl pod."
      Responded with event Validation: valid
      Context Attributes,
        specversion: 0.2
        type: dev.knative.samples.hifromknative
        source: knative/eventing/samples/hello-world
        id: 37458d77-01f5-411e-a243-a459bbf79682
      Data,
        {"msg":"Hi from Knative!"}

      ```
  Play around with the CloudEvent attributes in the curl command and the trigger specification to understand how [Triggers work](../../../broker-trigger.md#trigger).

## Verify reply from helloworld-go app
`helloworld-go` app replies back with an event of `type= dev.knative.samples.hifromknative`, and `source=knative/eventing/samples/hello-world`. This event enters the eventing mesh via the Broker and can be delivered to other services using a Trigger

  1. Deploy a pod that receives any CloudEvent and logs the event to its output.
      ```shell
      kubectl --namespace knative-samples apply --filename - << END
      # event-display app deploment
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: event-display
        namespace: knative-samples
      spec:
        replicas: 1
        selector:
          matchLabels: &labels
            app: event-display
        template:
          metadata:
            labels: *labels
          spec:
            containers:
              - name: helloworld-go
                image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
      ---
      # Service that exposes event-display app.
      # This will be the subscriber for the Trigger
      kind: Service
      apiVersion: v1
      metadata:
        name: event-display
        namespace: knative-samples
      spec:          
        selector:
          app: event-display
        ports:
          - protocol: TCP
            port: 80
            targetPort: 8080
      END
      ```
  
  1. Create a trigger to deliver the event to the above service
      ```shell
      kubectl --namespace knative-samples apply --filename - << END
      apiVersion: eventing.knative.dev/v1alpha1
      kind: Trigger
      metadata:
        name: event-display
        namespace: knative-samples
      spec:
        broker: default
        filter:
          attributes:
            type: dev.knative.samples.hifromknative
            source: knative/eventing/samples/hello-world
        subscriber:
          ref:
            apiVersion: v1
            kind: Service
            name: event-display
      END
      ```

  1. [Send a CloudEvent to the Broker](###Send-CloudEvent-to-the-Broker)

  1. Check the logs of event-display service
      ```shell
      kubectl --namespace knative-samples logs -l app=event-display --tail=50
      ```
      You should see something similar to:
      ```shell
        cloudevents.Event
        Validation: valid
        Context Attributes,
          specversion: 0.3
          type: dev.knative.samples.hifromknative
          source: knative/eventing/samples/hello-world
          id: 8a7384b9-8bbe-4634-bf0f-ead07e450b2a
          time: 2019-10-04T22:53:39.844943931Z
          datacontenttype: application/json
        Extensions,
          knativearrivaltime: 2019-10-04T22:53:39Z
          knativehistory: default-kn2-ingress-kn-channel.knative-samples.svc.cluster.local
          traceparent: 00-4b01db030b9ea04bb150b77c8fa86509-2740816590a7604f-00
        Data,
          {
            "msg": "Hi from helloworld-go app!"
          }
      ```

  **Note: You could use the above approach to test your applications too.**
 


## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename sample-app.yaml
```
