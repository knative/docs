# Consuming AWS SQS Events with Knative Eventing

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In a [previous post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"} we discussed the consumption of notifications from an AWS S3 bucket using Apache Camel K. While this is a good approach for getting data from cloud providers, like AWS, into Knative, the Knative Eventing team is aiming to integrate this at the core of its offering with a new CRD, the `IntegrationSource`. This post will describe howto receive SQS notifications and forward them to a regular Knative Broker for further processing._

## Installation

The `IntegrationSource` will be part of Knative Eventing in a future release. Currently it is under development but already included in the `main` branch. For installing Knative Eventing from the sources you can follow the [develpoment guide](https://github.com/knative/eventing/blob/main/DEVELOPMENT.md){:target="_blank"}.

!!! note

    Installing Knative Eventing from the source repository is not recommended for production cases. The purpose of this blog post is to give an early introduction to the new `IntegrationSource` CRD..

## Creating a Knative Broker instance

Once the `main` branch of Knative Eventing is installed we are using a Knative Broker as the heart of our system, acting as an [Event Mesh](https://knative.dev/docs/eventing/event-mesh/){:target="_blank"} for both event producers and event consumers:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  namespace: default
  name: my-broker
```

Now event producers can send events to it and event consumers can receive events.

## Using IntegrationSource for AWS SQS

In order to send data from AWS SQS to a Knative component, like the broker we created above, we are using the new `IntegrationSource` CRD. It basically allows to declaratively move data from a system, like AWS SQS, _towards_ a Knative resource, like our above Broker:

```yaml
apiVersion: sources.knative.dev/v1alpha1
kind: IntegrationSource
metadata:
  name: aws-sqs-source
spec:
  aws:
    sqs:
      queueNameOrArn: "my-queue"
      region: "my-queue"
      visibilityTimeout: 20
    auth:
      secret:
        ref:
          name: "my-secret"
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: my-broker
```

The `IntegrationSource` has an `aws` field, for defining different Amazon Web Services, such as `s3`, `ddb-streams` or like in this case `sqs`. Underneath the `aws` property is also a reference to a _Kubernetes Secret_, which contains the credentials for connecting to AWS. All SQS notifications are processed by the source and being forwarded as CloudEvents to the provided `sink`

!!! note

    If you compare the `IntegrationSource` to the `Pipe` from Apache Camel on the [previous article](/blog/articles/consuming_s3_data_with_knative){:target="_blank"} you will notice the new resource is less verbose and is directly following established Knative development principles, like any other Knative Event Source.

## Creating the Kubernetes Secret for the IntegrationSource

For connecting to any AWS service the `IntegrationSource` uses regular Kubernetes `Secret`s, present in the namespace of the resource. The `Secret` can be created like:

```
$ kubectl -n <namespace> create secret generic <secret-name> --from-literal=aws.accessKey=<...> --from-literal=aws.secretKey=<...> 
```

## Setting up the Consumer application

Now that we have the `Broker` and the `IntegrationSource` connected to it, it is time to define an application that is receiving _and_ processing the SQS notifications:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-receiver
  labels:
    app: log-receiver
spec:
  containers:
  - name: log-receiver
    image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
    imagePullPolicy: Always
    ports:
    - containerPort: 8080
      protocol: TCP
      name: log-receiver
---
apiVersion: v1
kind: Service
metadata:
  name: log-receiver
spec:
  selector:
    app: log-receiver
  ports:
    - port: 80
      protocol: TCP
      targetPort: log-receiver
      name: http
```

Here we define a simple `Pod` and its `Service`, which points to an HTTP-Server, that receives the CloudEvents. As you can see, this is **not** a AWS SQS specific consumer. Basically _any_ HTTP Webserver, in any given language, can be used for processing the CloudEvents coming from a Knative Broker.

## Subscribe the Consumer application to AWS SQS events

In order to be able to receive the SQS event notifications, we need to create a `Trigger` for our _Consumer application_:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: aws-sqs-trigger
spec:
  broker: my-broker
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: log-receiver
```

For debugging purpose we create a `Trigger` without any `filters` so it will forward _all_ CloudEvents to the `log-receiver` application. Once deployed, in the log of the `log-receiver` pod we should be seeing the following for any produced SQS notification on our queue:

```
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: dev.knative.connector.event.aws-sqs
  source: dev.knative.eventing.aws-sqs-source
  subject: aws-sqs-source
  id: 9CC70D09569020C-0000000000000001
  time: 2024-11-08T07:34:16.413Z
  datacontenttype: application/json
Extensions,
  knativearrivaltime: 2024-11-08T07:34:16.487697262Z
Data,
  <test data notification>
```

## Conclusion and Outlook

With the new `IntegrationSource` we will have a good way to integrate services from public cloud providers like AWS, by leveraging Apache Camel Kamelets behind the scenese. The initial set of services is on AWS, like `s3`, `sqs` or `ddb-streams`. However we are planning to add support for different services and providers. 

Since Apache Camel Kamelets can also act as `Sink`s, the team is working on providing a `IntegrationSink`, following same principles. 
