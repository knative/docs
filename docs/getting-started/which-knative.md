# Which Knative Component Should I Use?

Knative is a project that simplifies the deployment of applications onto Kubernetes. Knative, as a project, contains a few different components. The purpose of this document is to explain them and advise on when you would use a specific component. 


## Knative Serving

[Knative Serving](https://knative.dev/docs/serving/) defines a set of objects as Kubernetes Custom Resource Definitions (CRDs). These resources are used to define and control how your serverless workload behaves on the cluster.

In short, a user is able to deploy a containerized application on Kubernetes using Knative Serving. The Knative Serving components handle traffic routing, scaling, revision tracking as well as security and other configurations. It makes it easy to deploy applications on Kuberntes to where you don't even need to use Kubernetes. 

Knative Serving is best used for applications. Some examples are as follows:

- frontend web applications
- backend services
- batch processes
- API serving
- AI Inferencing

One thing worth noting is that most all of these services require an endpoint. While HTTP/S is the most common protocol, there are ways to get [gRPC to work](https://github.com/knative/docs/tree/main/code-samples/serving/grpc-ping-go).

A simple question to ask is whether or not your service is invoked by an HTTP request. If it is, then Knative Serving is the component to utilize. 



## Knative Eventing

[Knative Eventing](https://knative.dev/docs/eventing/) is a collection of APIs that enable you to use an [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture) with your applications. You can use these APIs to create components that route events from event producers (known as sources) to event consumers (known as sinks) that receive events. Sinks can also be configured to respond to HTTP requests by sending a response event.

With Knative Eventing, developers can simplify the binding of event sources to consumers. It acts as an abstraction between your services and the event sources that they must connect to. 

Currently, supported event sources are as follows

- [API Server Source](https://knative.dev/docs/eventing/sources/apiserversource/)
- [Apache CouchDB](https://couchdb.apache.org/)
- [Apache Kafka](https://kafka.apache.org/)
- [Ceph](https://ceph.io)
- [ContainerSource](https://knative.dev/docs/eventing/custom-event-source/containersource/)
- [GitHub](https://github.com)
- [GitLab](https://gitlab.com)
- [Kogito] (https://kogito.kie.org/)
- [PingSource](https://knative.dev/docs/eventing/sources/ping-source/)
- [RabbitMQ](https://rabbitmq.com)
- [Redis](https://redis.io)
- [SinkBinding](https://knative.dev/docs/eventing/custom-event-source/sinkbinding/)

There are a number of third-party sources that can be found [here](https://knative.dev/docs/eventing/sources/#third-party-sources).

Knative Eventing isn't used for applications but rather to bind event producers with event consumers in a declarative way. You wouldn't use Knative Eventing to host a [Python Flask](https://flask.palletsprojects.com/en/3.0.x/) application for example. 

If you are wanting to declaratively bind an event source to your application, you will use Knative Eventing. In particular, if you are using any of the aforementioned applications as a messaging queue or database then you will use Eventing.

## Knative Functions
A new addition to Knative are [Knative Functions](https://knative.dev/docs/functions/). This is meant for developers who are more familiar/comfortable with [Functions-as-a-Service (FaaS)](https://en.wikipedia.org/wiki/Function_as_a_service). 

Learning containerization does provide a learning curve for some and Knative Functions enables developers to focus purely on code. It is still Kubernetes under the hood so platform engineers still have the flexibility to design their platform. 

Since this is still Kubernetes under the hood, an [Open Container Initiative (OCI) format](https://opencontainers.org/about/overview/) container is still created and deployed. The key here is that the Knative Functions abstraction automates the creation and deployment of the container. 

This option is best for those whose developers may not be as familiar with OCI containers or if you want your developers to focus primarily on their code and not other primitives related to Knative or Kubernetes. 