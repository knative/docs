# Migrating Functions from AWS Lambda to Knative Functions using Golang

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In a [previous post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"} we discussed the consumption of notifications from an AWS S3 bucket inside a Knative Function. This post will describe the migration from a AWS Lambda Function, receiving S3 notifications, to [Knative Functions](docs/functions){:target="_blank"}._

With Serverless Functions one of the common use-cases is to execute custom code based on an event trigger, like a notification from the AWS S3 service. With AWS Lambda you can run those programs on Amazon's cloud offerings, but running the code on your own data-center is much harder.

## A Lambda Function for AWS S3

Taking a look at a Lambda [sample repository](https://github.com/aws/aws-lambda-go/blob/main/events/README_S3.md){:target="_blank"} shows a minimal, yet complete function for receiving AWS S3 event notifications. Lets take a look at the code:

```go
// main.go
package main

import (
	"fmt"
	"context"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/events"
)

func handler(ctx context.Context, s3Event events.S3Event) {
  	for _, record := range s3Event.Records {
      		s3 := record.S3
      		fmt.Printf("[%s - %s] Bucket = %s, Key = %s \n", record.EventSource, record.EventTime, s3.Bucket.Name, s3.Object.Key)
  	}
}


func main() {
	// Make the handler available for Remote Procedure Call by AWS Lambda
	lambda.Start(handler)
}
```

You see two functions here: `handler` for the custom application logic and `main` which calls some AWS Lambda APIs which register the custom handler. The signature of `handler` references the standard `Context` and an `S3Event` from the AWS Lambda SDK. In order to be able to run the function one needs two vendor-specific dependencies and a `main` function.  These are not directly related to the actual program, but are necessary technical plumbing in order to start the custom `handler` and register it to receive events.


## A Simpler Knative Function for AWS S3

!!! note

    To learn more about Knative Functions and how to create, build and deploy a project using the `func` CLI, check out the [documentation](docs/functions){:target="_blank"}.


In the [previous post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"} we discuss how to consume notifications from AWS Lambda in an on-premise cluster using Knative Eventing. Lets take a look at the `main.go` file from the S3 project again:

```go
package function

import (
	"context"
	"fmt"

	"github.com/cloudevents/sdk-go/v2/event"
)

// Handle an event.
func Handle(ctx context.Context, ce event.Event) (*event.Event, error) {
	fmt.Println("Received S3 event notification")
	fmt.Println("CloudEvent Subject attribute: " + ce.Subject())
	fmt.Println("CloudEvent Source attribute:  " + ce.Source())

  // Some processing of the payload of the CloudEvent...

	return nil, nil
}
```

Note that this complete program contains only one function, which is focused on the processing of the incoming events.  There is no need for `main`, or to register our event handler with middleware.  Therefore, there is also no need for imports. Knative Functions handles creating the process boundary and applying middleware automatically.

Looking closer at the signature of the `Handle` function, we see the standard `Context` API and an `Event` type. This is no vendor specific import. It references the Golang SDK for [CNCF CloudEvents](https://www.cncf.io/projects/cloudevents/){:target="_blank"}, which is a specification for describing event data in a common way.

In this example the `subject` is mapped to the name of the file, or the S3 Object Key, while the `source` attribute is containing the bucket name. In case the entire file is desired for processing, it can be accessed via the `data` attribute.

!!! note

    The CNCF CloudEvents specification allows a generic and independent approach for receiving events from 3rd party systems, while providing a common, standardized API.


## Knative CLI for Smooth Development and Deployment

The Knative Function project does not only offer a vendor-neutral approach for creating serverless functions, it also comes with a handy CLI that assists with the creation of the Linux container image and the deployment to a Kubernetes cluster.  This is covered in the [previous blog post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"}. It also allows you to test and run the function locally by  invoking:

```
$ func run
```

The log for the program reads like:

```
Building function image
🙌 Function built: <your-container-registry>/<account>/<image>:<tag>
Initializing CloudEvent function
listening on http port 8080
Running on host port 8080
```

Now you can simply test the Knative Function on your machine, like:

```
$ curl -v -X POST \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: /my/file/storage"  \
    -H "ce-type: test.event.type"  \
    -H "ce-subject: test-file.txt"  \
    -H "ce-id: $(uuid)"  \
    http://127.0.0.1:8080
```


## Conclusion

With Knative Functions it is straightforward to build cloud vendor-neutral functions for consuming event notifications from 3rd party cloud services such as AWS S3. Deploying those functions as Linux containers to your own on-premise Kubernetes cluster is also supported by the Knative CLI, as well as testing the function locally.

To learn more about Knative Functions visit the [documentation](docs/functions){:target="_blank"} on our website or join our CNCF Slack channel [#knative-functions](https://cloud-native.slack.com/archives/C04LKEZUXEE)!
