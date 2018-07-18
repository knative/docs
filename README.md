# Welcome, Knative

Knative (pronounced kay-nay-tiv) extends Kubernetes to provide the
missing middleware that developers need to create modern,
source-centric, container-based, cloud-native applications.

Each of the components under the Knative project attempt to identify
common patterns and codify the best practices shared by successful
real-world Kubernetes-based frameworks and applications, such as:

- [Orchestrating source-to-container workflows on Kubernetes](build/README.md)
- [Deploying a container to Knative](install/getting-started-knative-app.md)
- [Updating your application without downtime](serving/samples/blue-green-deployment.md)
- [Automatic scaling and sizing applications based on demand](serving/auto-scaling-with-knative.md)
- [Binding events to functions, apps, and containers with Knative](events/)

Knative focuses on the "boring but difficult" parts that everyone
needs, but that no one benefits from doing over again on their own. This
in turn frees application developers to spend more time writing
interesting code, not worrying about how they are going to build,
deploy, monitor, and debug it.

## Available Knative components

The following Knative components are currently available:

* [Build](https://github.com/knative/build) - Source to container build orchestration
* [Events](https://github.com/knative/eventing) - Management and delivery of events
* [Serving](https://github.com/knative/serving) - Scale to zero, request-driven compute

## Knative documentation

### Getting started with Knative

* [Installing Knative](/install/README.md)
* [Getting Started with Knative App Deployment](install/getting-started-knative-app.md)
* [Knative Sample Applications](serving/samples/README.md)

### Logging, Metrics, and Debugging 

* [Installing Logging, Metrics and Traces](./serving/installing-logging-metrics-traces.md)
* [Accessing Logs](./serving/accessing-logs.md)
* [Accessing Metrics](./serving/accessing-metrics.md)
* [Accessing Traces](./serving/accessing-traces.md)
* [Debugging Application Issues](./serving/debugging-application-issues.md)
* [Debugging Performance Issues](./serving/debugging-performance-issues.md)
* [Setting up a logging plugin](./serving/setting-up-a-logging-plugin.md)

### Networking

* [Using a Custom Domain with Knative](./serving/using-a-custom-domain.md)

### Configuration

* [Setting up a Docker Registry](./serving/setting-up-a-docker-registry.md)

## Who Knative is for

Knative is designed for different personas:

### Developers

Knative components offer Kubernetes-native APIs for deploying
serverless-style functions, applications, and containers to an auto-scaling
runtime.

To join the conversation, head over to the
[Knative Users](https://groups.google.com/d/forum/knative-users) Google group.

### Operators

Knative components are intended to be integrated into more polished
products that cloud service providers or in-house teams in large
enterprises can then operate.

Any enterprise or cloud provider can adopt Knative components into
their own systems and pass the benefits along to their customers.

### Contributors

With a clear project scope, lightweight governance model, and clean
lines of separation between pluggable components, the Knative project
establishes an efficient contributor workflow.

Knative is a diverse, open, and inclusive community. To get involved, see
[CONTRIBUTING.md](community/CONTRIBUTING.md)
and join the [Knative community](community/README.md).

Your own path to becoming a Knative contributor can
[begin anywhere](https://github.com/knative/serving/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22).
[Bug reports](https://github.com/knative/serving/issues/new) and
friction logs from new developers are especially welcome.
