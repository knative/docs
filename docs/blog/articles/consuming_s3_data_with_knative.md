# Consuming AWS S3 Events with Knative Eventing, Functions and Apache Camel K

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In this blog post you will learn how to easily consume events from an AWS S3 bucket in a Knative Function with Knative Eventing and Functions. The blog post builds up on the [first post](/blog/articles/knative-meets-apache-camel){:target="_blank"} of the series on Apache Camel K and Knative_

One of the typical use-cases for a Serverless Function is to react to events delivered by an external source of events. A common example of this is to receive notifications from an AWS S3 bucket in a Serverless Function. But how can you receive those events in an on premise environment, where instead of running on AWS the function runs on a custom Kubernetes setup? 

## Installation

The [Installation](https://camel.apache.org/camel-k/next/installation/installation.html){:target="_blank"} from Apache Camel K offers a few choices, such as CLI, Kustomize, OLM or Helm. For example, the Helm installation is:

```
$ helm repo add camel-k https://apache.github.io/camel-k/charts/
$ helm install my-camel-k camel-k/camel-k
```

Besides Camel K we also need to have Knative Eventing installed, as described in the [documentation](https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml/){:target="_blank"}.

## Creating a Knative Broker instance

We are using a Knative Broker as the heart of our system, acting as an [Event Mesh](https://knative.dev/docs/eventing/event-mesh/){:target="_blank"} for both event producers and event consumers:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  namespace: default
  name: my-broker
```

Now event producers can send events to it and event consumers can receive events.

## Using Kamelets as Event Sources for AWS S3

In order to _bind_ a Kamelet to a Knative component, like the broker we created above, we are using the `Pipe` API. A Pipe allows to declaratively move data from a system described by a Kamelet _towards_ a Knative resource **or** _from_ a Knative resource to another (external) system described by a Kamelet.

Below is a `Pipe` that uses a ready-to-use `Kamelet`, a `aws-s3-source`

```yaml
apiVersion: camel.apache.org/v1
kind: Pipe
metadata:
  name: aws-s3-source-pipe
  annotations:
    trait.camel.apache.org/mount.config: "secret:aws-s3-credentials"
spec:
  integration:
    dependencies:
    - "camel:cloudevents"
  source:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1
      name: aws-s3-source
    properties:
      bucketNameOrArn: "${aws.s3.bucketNameOrArn}"
      accessKey: "${aws.s3.accessKey}"
      secretKey: "${aws.s3.secretKey}"
      region: "${aws.s3.region}"
    dataTypes:
      out:
        scheme: aws2-s3
        format: application-cloudevents
  sink:
    dataTypes:
      in:
        scheme: http
        format: application-cloudevents
    ref:
      kind: Broker
      apiVersion: eventing.knative.dev/v1
      name: my-broker
```


The `aws-s3-source` Kamelet is referenced as the `source` of the `Pipe` and sends CNCF CloudEvents to the outbound `sink`, when there is activity in the referenced bucket. Here we use the Knative Broker, which accepts CloudEvents. Later we will connect a Knative Function to the Broker for receiving events from it.

!!! note

    The AWS S3 properties are stored in a secret, which is mounted into the `Pipe`, via the `trait.camel.apache.org/mount.config` annotation.


## Creating a Knative Function as a consumer

In order to consume messages from the Knative broker, using Knative Function, we need will create a simple Golang function. Since the payload is sent as CloudEvents to the function we use the buildin `cloudevents` template, by executing the the following command:

```
$ func create -l go -t cloudevents s3-logger
```

This gives you a new project in the `s3-logger` folder of your current directory, and it contains a Golang file for the Knative Function:

```go
package function

import (
	"context"
	"fmt"

	"github.com/cloudevents/sdk-go/v2/event"
)

// Handle an event.
func Handle(ctx context.Context, ce event.Event) (*event.Event, error) {
	/*
	 * YOUR CODE HERE
	 *
	 * Try running `go test`.  Add more test as you code in `handle_test.go`.
	 */

	fmt.Println("Received event")
	fmt.Println(ce) // echo to local output
	return &e, nil // echo to caller
}
```

We can now modify the `Handle` function to print out a few attributes of the CloudEvent:

```go
func Handle(ctx context.Context, ce event.Event) (*event.Event, error) {
	fmt.Println("Received S3 event notification")
	fmt.Println("CloudEvent Subject attribute: " + ce.Subject())
	fmt.Println("CloudEvent Source attribute:  " + ce.Source())

  // Some processing of the payload of the CloudEvent...

	return nil, nil
```


The above `Handle` function just prints the filename, represented by the `subject` attribute and the full qualified name of the bucket, which is stored as the `source` attribute of the received CloudEvent.

!!! note

    Currently the AWS-S3-Source sends the entire data, so the full file is also accessible via the `data` property.

## Subscribe the Knative Function to AWS S3 events

In order to be able to receive the S3 event notifications, we need to subscribe the function to the broker, which provides the events. But how do we know what events are available? For that we check what Knative EventTypes are available in the system:

```
$ kubectl get eventtypes.eventing.knative.dev 
NAME                                            TYPE                                      SOURCE                       SCHEMA   REFERENCE NAME   REFERENCE KIND   DESCRIPTION                             READY   REASON
et-my-broker-53bfa9803446c35c5a612c5a44a1c263   org.apache.camel.event.aws.s3.getObject   aws.s3.bucket.<bucketname>            my-broker        Broker           Event Type auto-created by controller   True
```

Now we know that in our namespace there are `org.apache.camel.event.aws.s3.getObject` events available on the `my-broker` broker.


We can now perform the subscription of the function to that event type from the given broker:

```
$ func subscribe --filter type=org.apache.camel.event.aws.s3.getObject --source my-broker
```

This updates the `func.yaml` metadata of the project and when the function is being deployed, the CLI will build and deploy the consumer and creates a Knative `Trigger` for it, with matching filter arguments:

```
$ func deploy
```

Once deployed, on the terminal of the Knative Function the following output is visible for _each_ S3 event:

```
Received S3 event notification

CloudEvent Subject attribute: my-file.txt
CloudEvent Source attribute:  aws.s3.bucket.<bucketname>
```

## Conclusion

With Knative Eventing, Functions and Apache Camel K it is possible to trigger notifications from 3rd party cloud services, such as AWS S3, to functions running on your own on-premise Kubernetes cluster. 
