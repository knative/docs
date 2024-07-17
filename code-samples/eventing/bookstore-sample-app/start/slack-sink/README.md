# Bookstore Notification Service: with Apache Camel K and Knative Eventing


As a bookstore owner, you aim to receive instant notifications in a Slack channel whenever a customer submits a new review comment. By leveraging Knative Eventing and Apache Camel K, you can set up an event-driven service that automates these notifications, ensuring you're always informed.
## What Knative features will we learn about?
- Knative's ability to connect with third-party services, such as Slack, through event-driven integration using Apache Camel K.

## What does the final deliverable look like?
When a CloudEvent with the type `new-review-comment` is sent to the Knative Eventing Broker, it triggers a message to be sent in a designated Slack channel.

## Install prerequisites

### Prerequisite 1: Install Camel CLI
Install the Camel K CLI (`kamel`) on your local machine. You can find the installation instructions [here](https://camel.apache.org/camel-k/2.2.x/cli/cli.html){:target="_blank"}.

**Troubleshot**: If after installation you run `kamel version` and you get an error message, you may need to add the `kamel` binary to your system's PATH. You can do this by moving the `kamel` binary to a directory that is already in your PATH, or by adding the directory where `kamel` is located to your PATH.

```bash
$ export PATH=$PATH:<path-to-kamel-binary>
```


### Prerequisite 2: Install Apache Camel-Kamelets
Next, install Camel K on your cluster using the Camel K CLI:

```bash
$ kamel install --registry docker.io --organization <your-organization> --registry-auth-username <your-username> --registry-auth-password <your-password>
```

Replace the placeholders with your actual Docker registry information.

If you are using other container registries, you may need to read more [here](https://camel.apache.org/camel-k/2.2.x/installation/registry/registry.html){:target="_blank"} for the installation. 

You will see this message if the installation is successful:

```
OLM is not available in the cluster. Fallback to regular installation.
Camel K installed in namespace default
```
### Prerequisite 3: Create a Slack App and Generate an Incoming Webhook URL
Follow the instruction here on how to create the slack workspace and generate an incoming webhook URL for your designated channel where notifications will be sent.

## Implementation
### Step 1: Create the Broker

This Broker is created solely for testing purposes and is intended for temporary use during this part of the tutorial only. 

**Method 1**: Initialize a Broker within your Kubernetes cluster using the Knative CLI:

```bash
$ kn broker create book-review-broker
```
You will see this message if the Broker is created successfully:

```
Broker 'book-review-broker' successfully created in namespace 'default'.
```
**Method 2**: You can create a new YAML file to create the Broker:

*new-knative-broker.yaml*
```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: book-review-broker
  namespace: default
```
After you saved the file, you can apply the configuration to your Kubernetes cluster:

```bash
$ kubectl apply -f new-knative-broker.yaml
```
You will see this message if the Broker is created successfully:

```
broker.eventing.knative.dev/book-review-broker created
```


### Step 2: Configure the Slack Sink

We use a feature called "Pipe" in Apache Camel K to link event sources and destinations. Specifically, the Pipe connects events from a Broker, our source, to a Slack channel through a Slack sink Kamelet, our destination. This setup automatically sends notifications to Slack whenever new events occur, streamlining the flow of information.


1. Create a Slack app and generate an incoming webhook URL for your designated channel where notifications will be sent. Refer to Slack documentation for how to do this.

2. Prepare the YAML configuration for the Slack sink, which will forward events to your Slack channel:

*slack-sink.yaml*
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

```bash
$ kubectl apply -f slack-sink.yaml
```
You will see this message if the configuration is created successfully:

```
pipe.camel.apache.org/slack-sink-pipe created
```
But this process will take a few seconds to complete. You can check the status of the pipe by running the following command:

```bash
$ kubectl get pipe slack-sink-pipe

NAME              PHASE      REPLICAS
slack-sink-pipe   Ready      1
```



### Step 3: Testing by Triggering Notifications

To trigger notifications, you'll need to simulate an event that matches the criteria set in your Slack sink configuration. For example, submitting a book review could be an event of type `new-review-comment`.

Directly sending CloudEvents to a Broker using curl from an external machine (like your local computer) is typically **constrained** due to the networking and security configurations of Kubernetes clusters.

Therefore, you need to create a new pod in your Kubernetes cluster to send a CloudEvent to the Broker. You can use the following command to create a new pod:

```bash
$ kubectl run curler --image=radial/busyboxplus:curl -it --restart=Never
```
You will see this message if you successfully entered the pod's shell

```
If you don't see a command prompt, try pressing enter.
[root@curler:/]$ 
```


Using curl command to send a CloudEvents to the Broker:
```bash
[root@curler:/]$ curl -v "<The URI to your broker>" \
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
$ kubectl get broker book-review-broker

NAME                 URL                                                                                   AGE     READY   REASON
book-review-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/book-review-broker   5m37s   True
```

Wait a few seconds, and you should see a notification in your Slack channel. Congratulations! You have successfully set up the notification service for your bookstore.
## Conclusion

In this tutorial, you learned how to set up an event-driven service that automates notifications to a Slack channel using Knative Eventing and Apache Camel K. By leveraging these technologies, you can easily connect your applications to third-party services, and pass information between them in real-time. 
