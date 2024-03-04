# Bookstore Notification Service: with Apache Camel K and Knative Eventing

This guide details how to implement a notification service within a bookstore web application that leverages Apache Camel K, Knative, and Slack. This setup enables the bookstore to send automated notifications to a designated Slack channel when specific events occur, such as the submission of a negative review or an announcement within the application.

## Overview

The notification service is designed to enhance user engagement by providing timely updates through Slack notifications. It integrates with external APIs to send these notifications and uses event-driven triggers to initiate them based on user actions or system events.

## What does the final deliverable look like?
1. You send a CloudEvent with the review comment to the broker that matches the criteria set in the Slack sink configuration.
2. The Slack sink consumes the CloudEvent and sends a notification to the designated Slack channel.
3. The notification appears in the Slack channel, informing the bookstore owner about the new review comment.

## Prerequisites

- Access to a Kubernetes cluster with Knative Eventing and Serving installed.
- The Camel K CLI (`kamel`) installed on your local machine.
- Apache Camel-Kamelets Version 4.4.x or later.
- A Slack workspace with the ability to create incoming webhooks. You can follow the link here to learn more about how to set up the slack workspace.

[//]: # (# FIXME: Add link to Slack documentation)

## Installation Steps

### Step 1: Install Knative and Camel K

Ensure that Knative Eventing and Serving are installed on your Kubernetes cluster. Follow the official [Knative quickstart guide](https://knative.dev/docs/install/quickstart-install/) if necessary. Use the kn quick start command to install both Knative Eventing and Knative Serving components on your Kubernetes cluster is an easy way.

Next, install Camel K on your cluster using the Camel K CLI:

```bash
$ kamel install --registry docker.io --organization <your-organization> --registry-auth-username <your-username> --registry-auth-password <your-password>
```

Replace the placeholders with your actual Docker registry information.

If you are using other container registries, you may need to read more [here](https://camel.apache.org/camel-k/2.2.x/installation/registry/registry.html) for the installation. 

You will see this message if the installation is successful:

```
OLM is not available in the cluster. Fallback to regular installation.
Camel K installed in namespace default
```
### Step 2: Create the Broker

Initialize a default broker within your Kubernetes cluster using the Knative CLI:

```bash
$ kn broker create book-review-broker
```
You will see this message if the broker is created successfully:

```
Broker ‘book-review-broker’ successfully created in namespace ‘default’.
```

### Step 3: Configure the Slack Sink

1. Create a Slack app and generate an incoming webhook URL for your designated channel where notifications will be sent. Refer to Slack documentation for how to do this.

2. Prepare the YAML configuration for the Slack sink, which will forward events to your Slack channel:

```yaml
apiVersion: camel.apache.org/v1
kind: Pipe
metadata:
  name: bookstore-notification-service
spec:
  source:
    ref:
      kind: Broker
      apiVersion: eventing.knative.dev/v1
      name: default
    properties:
      type: new-review-comment
  sink:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1
      name: slack-sink
    properties:
      channel: “#bookstore-owner”
      webhookUrl: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

Make sure to replace `#your-channel` and the `webhookUrl` with your actual Slack channel name and webhook URL.


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



### Step 4: Testing by Triggering Notifications

To trigger notifications, you'll need to simulate an event that matches the criteria set in your Slack sink configuration. For example, submitting a book review could be an event of type `new-review-comment`.

```bash
$ kubectl exec -it curler -- /bin/bash

curl -v "<The URI to your broker>" \
-X POST \
-H "Ce-Id: review1" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: new-review-comment" \
-H "Ce-Source: bookstore-web-app" \
-H "Content-Type: application/json" \
-d 'Hello from Knative!'
```

You can find the URI to your broker by running the following command:

```bash
$ kubectl get broker book-review-broker

NAME                 URL                                                                                   AGE     READY   REASON
book-review-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/book-review-broker   5m37s   True
```

## Conclusion

By following these steps, you have integrated a notification service into your bookstore web application that leverages Apache Camel K and Knative to send event-driven notifications to a Slack channel. This service enhances user engagement by keeping them informed about important events within the bookstore application.

