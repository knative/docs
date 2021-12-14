# Knative Serving code samples

Use the following code samples to help you understand the various Knative
Serving resources and how they can be applied across common use cases.
[Learn more about Knative Serving](../serving/README.md).

See [all Knative code samples](https://github.com/knative/docs/tree/main/code-samples) in GitHub.

| Name               | Description                 | Languages                 |
| ------------------ | ----------------------------| :-----------------------: |
| Hello World        | A quick introduction that highlights how to deploy an app using Knative Serving. | [C#](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-csharp/), [Go](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-go), [Java (Spark)](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-java-spark), [Java (Spring)](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-java-spring), [Kotlin](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-kotlin), [Node.js](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-nodejs), [PHP](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-php), [Python](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-python), [Ruby](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-ruby), [Scala](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-scala), [Shell](https://github.com/knative/docs/tree/main/code-samples/serving/hello-world/helloworld-shell) |
| Cloud Events        | A quick introduction that highlights how to send and receive Cloud Events. | [C#](https://github.com/knative/docs/tree/main/code-samples/serving/cloudevents/cloudevents-dotnet), [Go](https://github.com/knative/docs/tree/main/code-samples/serving/cloudevents/cloudevents-go), [Node.js](https://github.com/knative/docs/tree/main/code-samples/serving/cloudevents/cloudevents-nodejs), [Rust](https://github.com/knative/docs/tree/main/code-samples/serving/cloudevents/cloudevents-rust), [Java (Vert.x)](https://github.com/knative/docs/tree/main/code-samples/serving/cloudevents/cloudevents-vertx) |
| Traffic Splitting   | An example of manual traffic splitting. | [YAML](../serving/traffic-management.md) |
| Advanced Deployment | Simple blue/green-like application deployment pattern illustrating the process of updating a live application without dropping any traffic.                                                                              | [YAML](../serving/traffic-management.md#routing-and-managing-traffic-with-bluegreen-deployment) |
| Autoscale           | A demonstration of the autoscaling capabilities of Knative. | [Go](../serving/autoscaling/autoscale-go/README.md) |
| Github Webhook      | A simple webhook handler that demonstrates interacting with Github. |  [Go](https://github.com/knative/docs/tree/main/code-samples/serving/gitwebhook-go) |
| gRPC                | A simple gRPC server.  | [Go](https://github.com/knative/docs/tree/main/code-samples/serving/grpc-ping-go)  |
| Knative Routing     | An example of mapping multiple Knative services to different paths under a single domain name using the Istio VirtualService concept.   | [Go](https://github.com/knative/docs/tree/main/code-samples/serving/knative-routing-go)  |
| Kong Routing     | An example of mapping multiple Knative services to different paths under a single domain name using the Kong API gateway. | [Go](https://github.com/knative/docs/tree/main/code-samples/serving/kong-routing-go) |
| Knative Secrets     | A simple app that demonstrates how to use a Kubernetes secret as a Volume in Knative.   | [Go](https://github.com/knative/docs/tree/main/code-samples/serving/secrets-go) |
| Multi Container     | A quick introduction that highlights how to build and deploy an app using Knative Serving for multiple containers. | [Go](https://github.com/knative/docs/tree/main/code-samples/serving/multi-container) |
