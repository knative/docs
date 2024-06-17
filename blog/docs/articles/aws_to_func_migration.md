# Migrating Functions from AWS Lambda to Knative Functions using Golang

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In a [previous post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"} we discussed the consumption of notifications from an AWS S3 bucket inside a Knative Function. This post will describe the migration from a AWS Lambda Function, receiving S3 notifications, to Knative Functions._

With Serverless Functions one of the common use-cases is to execute custom code based on an event trigger, like a notification from the AWS S3 service. With AWS Lambda you can run those programs on Amazon's cloud offerings, but running the code on your own data-center is much harder.

## A simple AWS Lambda function for AWS S3

Taking a look at their [sample repository](https://github.com/aws/aws-lambda-go/blob/main/events/README_S3.md){:target="_blank"} shows a minimal, yet complete function for receiving AWS S3 event notifications. Lets take a look at their code:

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

You see a two functions here, the `handler` function for the custom application logic and a `main` function which calls some AWS Lambda APIs and registers the custom handler with it. The signature of the `handler` references the standard `Context` and an `S3Event` from the AWS Lambda SDK. In order to be able to run the function you need a two vendor specific dependencies. The `main` function is also not specific to the actual program, but more technically needed in order have the custom `handler` receive events. 


## A much simpler Knative Function for AWS S3

In the [previous post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"} we already discussed how to consume notifications from AWS Lambda in an on-premise cluster using Knative Eventing, but lets take a look at the code again:

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

You will notice that this complete program contains only one function which is focused on the processing of the incoming events. You will notice that we do not need to write a `main` function to register our event handler with some middleware. Knative Functions does this all for you, behind the scenes. Looking closer at the signature of the `Handle` function you also notice the standard `Context` API and an `Event` type. This is no vendor specific import. It references to the Golang SDK for [CNCF CloudEvents](https://www.cncf.io/projects/cloudevents/){:target="_blank"}, which is a specification for describing event data in a common way.

## Knative CLI for smooth development and deployment

The Knative Function project does not only shine with its vendor-neutral approach for programming Serverless Functions, it also comes with a handy CLI that assists developers with the creation of the Linux container image and the deployment to a Kubernetes cluster, as already discussed in the [previous blog post](/blog/articles/consuming_s3_data_with_knative){:target="_blank"}, it also allows you to test and run the function locally, by just invoking:

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

With Knative Functions it is pretty straightforward to build vendor-neutral function for consuming event notifications from 3rd party cloud services, such as AWS S3. Deploying those functions as Linux containers to your own on-premise Kubernetes cluster is supported by the Knative CLI as well as testing the function locally.
