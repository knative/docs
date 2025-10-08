# Bookstore Notification Service: with Apache Camel K and Knative Eventing

As a bookstore owner, you aim to receive instant notifications in a Slack channel whenever a customer submits a new review comment. By leveraging Knative Eventing and Apache Camel K, you can set up an event-driven service that automates these notifications, ensuring you're always informed.

## What Knative features will we learn about?

- Knative's ability to connect with third-party services, such as Slack, through event-driven integration using Apache Camel K.

## What does the final deliverable look like?

When a CloudEvent with the type `new-review-comment` is sent to the Knative Eventing Broker, it triggers a message to be sent in a designated Slack channel.

## Install prerequisites

### Prerequisite 1: Install Apache Camel-Kamelets

Install Apache Camel K operator on your cluster using any of the methods listed in [the official installation docs](https://camel.apache.org/camel-k/2.8.x/installation/installation.html). We will use the installation via Kustomize:

```sh
kubectl create ns camel-k && \
kubectl apply -k github.com/apache/camel-k/install/overlays/kubernetes/descoped?ref=v2.8.0 --server-side
```

Now you need to setup an `IntegrationPlatform` with a container registry. You can read more about it in [the official installation docs](https://camel.apache.org/camel-k/2.8.x/installation/installation.html#integration-platform). For all our needs we only need to create the `IntegrationPlatform` CR with a container registry entry. For example let's say we're using a Kind cluster with a local registry named `kind-registry` on port `5000`. Then your `IntegrationPlatform` CR will look like the following:

```yaml
apiVersion: camel.apache.org/v1
kind: IntegrationPlatform
metadata:
  name: camel-k
  namespace: camel-k # Make sure this is the namespace where your operator is running
spec:
  build:
    registry:
      address: kind-registry:5000
      insecure: true
```

Install it with one command:

```sh
cat <<EOF | kubectl apply -f -
apiVersion: camel.apache.org/v1
kind: IntegrationPlatform
metadata:
  name: camel-k
  namespace: camel-k
spec:
  build:
    registry:
      address: kind-registry:5000
      insecure: true
EOF
```

If you are using other container registries, you may need to read more in the [container registry configuration docs](https://camel.apache.org/camel-k/2.8.x/installation/registry/registry.html#how-to-configure){:target="_blank"} for Apache Camel K.

## Implementation

### Step 1: Create the Broker

This Broker is created solely for testing purposes and is intended for temporary use during this part of the tutorial only. 

**Method 1**: Initialize a Broker within your Kubernetes cluster using the Knative CLI:

```sh
kn broker create book-review-broker
```

You will see this message if the Broker is created successfully:

```sh
Broker 'book-review-broker' successfully created in namespace 'default'.
```

**Method 2**: You can create a new YAML file to create the Broker:

*book-review-broker.yaml:*

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: book-review-broker
  namespace: default
```

After you saved the file, you can apply the configuration to your Kubernetes cluster:

```sh
 kubectl apply -f book-review-broker.yaml
```

You will see this message if the Broker is created successfully:

```sh
broker.eventing.knative.dev/book-review-broker created
```


### Step 2: Configure the Slack Sink

We use a feature called "Pipe" in Camel K to link event sources and destinations. Specifically, the Pipe connects events from a Broker, our source, to a Slack channel through a Slack sink Kamelet, our destination. This setup automatically sends notifications to Slack whenever new events occur, streamlining the flow of information.


1. Create a Slack app and generate an incoming webhook URL for your designated channel where notifications will be sent. Refer to [create Slack workspace](create-workspace.md) for how to do this.

2. Prepare the YAML configuration for the Slack sink, which will forward events to your Slack channel:

*slack-sink.yaml:*

```yaml
apiVersion: camel.apache.org/v1  # Specifies the API version of Camel K.
kind: Pipe  # This resource type is a Pipe, a custom Camel K resource for defining integration flows.
metadata:
  name: bookstore-notification-service  # The name of the Pipe, which identifies this particular integration flow.
spec:
  source:  # Defines the source of events for the Pipe.
    ref:
      kind: Broker  # Specifies the kind of source, in this case, a Knative Eventing Broker.
      apiVersion: eventing.knative.dev/v1  # The API version of the Knative Eventing Broker.
      name: book-review-broker  # The name of the Broker, "book-review-broker" in this case
    properties:
      type: new-review-comment  # A filter that specifies the type of events this Pipe will listen for, here it's listening for events of type "new-review-comment". You have to have this type specified.
  sink:  # Defines the destination for events processed by this Pipe.
    ref:
      kind: Kamelet  # Specifies that the sink is a Kamelet, a Camel K component for connecting to external services.
      apiVersion: camel.apache.org/v1  # The API version for Kamelet.
      name: slack-sink  # The name of the Kamelet to use as the sink, in this case, a predefined "slack-sink" Kamelet.
    properties:
      channel: “#bookstore-owner”  # The Slack channel where notifications will be sent.
      webhookUrl: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"  # The Webhook URL provided by Slack for posting messages to a specific channel.
```

Make sure to replace the `webhookUrl` with your actual Slack channel name and webhook URL.

3. Apply the configuration to your Kubernetes cluster:

```sh
kubectl apply -f slack-sink.yaml
```

You will see this message if the configuration is created successfully:

```sh
pipe.camel.apache.org/bookstore-notification-service created
```

But this process will take a few seconds to complete. You can check the status of the pipe by running the following command:

```bash
kubectl get pipe bookstore-notification-service

NAME                             PHASE      REPLICAS
bookstore-notification-service   Ready      1
```

### Step 3: Testing by Triggering Notifications

To trigger notifications, you'll need to simulate an event that matches the criteria set in your Slack sink configuration. For example, submitting a book review could be an event of type `new-review-comment`.

Directly sending CloudEvents to a Broker using curl from an external machine (like your local computer) is typically **constrained** due to the networking and security configurations of Kubernetes clusters.

Therefore, you need to create a new pod in your Kubernetes cluster to send a CloudEvent to the Broker. You can use the following command to create a new pod:

```sh
kubectl run curler --image=radial/busyboxplus:curl -it --restart=Never
```

You will see this message if you successfully entered the pod's shell

```sh
[root@curler:/]$ 
```

If you don't see a command prompt, try pressing enter.

Using curl command to send a CloudEvent to the Broker:

```sh
[root@curler:/]$ curl -v "<The URI to your Broker>" \
-X POST \
-H "Ce-Id: review1" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: new-review-comment" \
-H "Ce-Source: bookstore-web-app" \
-H "Content-Type: application/json" \
-d 'Hello from Knative!'
```

You can find the URI to your Broker by running the following command:

```bash
kubectl get broker book-review-broker

NAME                 URL                                                                                   AGE     READY   REASON
book-review-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/book-review-broker   5m37s   True
```

Wait a few seconds, and you should see a notification in your Slack channel. Congratulations! You have successfully set up the notification service for your bookstore.

## Conclusion

In this tutorial, you learned how to set up an event-driven service that automates notifications to a Slack channel using Knative Eventing and Apache Camel K. By leveraging these technologies, you can easily connect your applications to third-party services, and pass information between them in real-time.
