# Welcome, Native

Native (pronounced kay-nay-tiv) extends Kubernetes to provide a set of middleware 
components that are essential to build modern, source-centric, and container-based 
applications that can run anywhere: on premises, in the cloud, or even in a third-party 
data center. 

Each of the components under the Native project attempt to identify common patterns and 
codify the best practices that are shared by successful real-world Kubernetes-based frameworks and 
applications. Native components focus on solving many mundane but difficult tasks such as:

* [Deploying a container](./install/getting-started-native-app.md)
* [Orchestrating source-to-URL workflows on Kubernetes](./serving/samples/source-to-url-go/)
* [Routing and managing traffic with blue/green deployment](./serving/samples/blue-green-deployment.md)
* [Automatic scaling and sizing workloads based on demand](./serving/samples/autoscale-go)
* [Binding running services to eventing ecosystems](./eventing/samples/event-flow/README.md)

Developers on Native can use familiar idioms, languages, and frameworks to deploy any workload: 
functions, applications, or containers.

## Components

The following Native components are currently available:

* [Build](https://github.com/native/build) - Source-to-container build orchestration
* [Eventing](https://github.com/native/eventing) - Management and delivery of events
* [Serving](https://github.com/native/serving) - Request-driven compute that can scale to zero

## Audience

Native is designed with different personas in mind:

![Diagram that displays different Audiences for Native](./images/native-audience.svg)

### Developers

Native components offer developers Kubernetes-native APIs for deploying
serverless-style functions, applications, and containers to an auto-scaling
runtime.

To join the conversation, head over to the
[Native users](https://groups.google.com/d/forum/native-users) Google group.

### Operators

Native components are intended to be integrated into more polished
products that cloud service providers or in-house teams in large
enterprises can then operate.

Any enterprise or cloud provider can adopt Native components into
their own systems and pass the benefits along to their customers.

### Contributors

With a clear project scope, lightweight governance model, and clean
lines of separation between pluggable components, the Native project
establishes an efficient contributor workflow.

Native is a diverse, open, and inclusive community. To get involved, see
[CONTRIBUTING.md](./community/CONTRIBUTING.md)
and join the [Native community](./community/README.md).

Your own path to becoming a Native contributor can
[begin anywhere](https://github.com/native/serving/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22).
[Bug reports](https://github.com/native/serving/issues/new) and
friction logs from new developers are especially welcome.

## Documentation

Follow the links in this section to learn more about Native.

### Getting started

* [Installing Native](./install/README.md)
* [Getting started with app deployment](./install/getting-started-native-app.md)
* [Getting started with serving](./serving)
* [Getting started with builds](./build)
* [Getting started with eventing](./eventing)

### Configuration and networking

* [Configuring outbound network access](./serving/outbound-network-access.md)
* [Using a custom domain](./serving/using-a-custom-domain.md)
* [Assigning a static IP address for Native on Google Kubernetes Engine](./serving/gke-assigning-static-ip-address.md)
* [Configuring HTTPS with a custom certificate](./serving/using-an-ssl-cert.md)

### Samples and demos

* [Autoscaling](./serving/samples/autoscale-go/README.md)
* [Source-to-URL deployment](./serving/samples/source-to-url-go/README.md)
* [Binding running services to eventing ecosystems](./eventing/samples/event-flow/README.md)
* [Telemetry](./serving/samples/telemetry-go/README.md)
* [REST API sample](./serving/samples/rest-api-go/README.md)
* [All samples for serving](./serving/samples/)
* [All samples for eventing](./eventing/samples/)

### Logging and metrics 

* [Installing logging, metrics and traces](./serving/installing-logging-metrics-traces.md)
* [Accessing logs](./serving/accessing-logs.md)
* [Accessing metrics](./serving/accessing-metrics.md)
* [Accessing traces](./serving/accessing-traces.md)
* [Setting up a logging plugin](./serving/setting-up-a-logging-plugin.md)

### Debugging

* [Debugging application issues](./serving/debugging-application-issues.md)
* [Debugging performance issues](./serving/debugging-performance-issues.md)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
