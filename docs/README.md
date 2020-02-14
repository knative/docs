
Knative (pronounced kay-nay-tiv) extends
[Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)
to provide a set of middleware components that are essential to build modern,
source-centric, and container-based applications that can run anywhere: on
premises, in the cloud, or even in a third-party data center.

Each of the components under the Knative project attempt to identify common
patterns and codify the best practices that are shared by successful,
real-world, Kubernetes-based frameworks and applications. Knative components
focus on solving mundane but difficult tasks such as:

- [Deploying a container](./serving/getting-started-knative-app.md)
- [Routing and managing traffic with blue/green deployment](./serving/samples/blue-green-deployment.md)
- [Scaling automatically and sizing workloads based on demand](./serving/configuring-autoscaling.md)
- [Binding running services to eventing ecosystems](./eventing/samples/kubernetes-event-source/)

Developers on Knative can use familiar idioms, languages, and frameworks to
deploy functions, applications, or containers workloads.

## Components

Knative consists of the Serving and Eventing components:

- [Eventing](./eventing) - Management and delivery of events
- [Serving](./serving) - Request-driven compute that can scale to zero

## Audience

Knative is designed for different personas:

![Diagram that displays different Audiences for Knative](./images/knative-audience.svg)

### Developers

Knative components offer developers Kubernetes-native APIs for deploying
serverless-style functions, applications, and containers to an auto-scaling
runtime.

To join the conversation, head over to the
[Knative users](https://groups.google.com/d/forum/knative-users) Google group.

### Operators

Knative components are intended to be integrated into more polished products
that cloud service providers or in-house teams in large enterprises can then
operate.

Any enterprise or cloud provider can adopt Knative components into their own
systems and pass the benefits along to their customers.

### Contributors

With a clear project scope, lightweight governance model, and clean lines of
separation between pluggable components, the Knative project establishes an
efficient contributor workflow.

Knative is a diverse, open, and inclusive community. To get involved, see
[CONTRIBUTING.md](https://github.com/knative/community/tree/master/CONTRIBUTING.md) and join the
[Knative community](../community/).

Your own path to becoming a Knative contributor can begin in any of the
following components:

- [serving](https://github.com/knative/serving/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3Akind%2Fgood-first-issue)
- [eventing](https://github.com/knative/eventing/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3Akind%2Fgood-first-issue)
- [documentation](https://github.com/knative/docs/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3Akind%2Fgood-first-issue)

[Bug reports](https://github.com/knative/serving/issues/new) and friction logs
from new developers are especially welcome.

## Documentation

Follow the links below to learn more about Knative.

### Getting started

- [Installing Knative](./install/README.md)
- [Getting started with app deployment](./serving/getting-started-knative-app.md)
- [Getting started with serving](./serving)
- [Getting started with eventing](./eventing)

### Configuration and networking

- [Using a custom domain](./serving/using-a-custom-domain.md)
- [Assigning a static IP address for Knative on Google Kubernetes Engine](./serving/gke-assigning-static-ip-address.md)
- [Configuring HTTPS with a custom certificate](./serving/using-a-tls-cert.md)

### Samples and demos

- [Autoscaling](./serving/samples/autoscale-go/README.md)
- [Binding running services to eventing ecosystems](./eventing/samples/kubernetes-event-source/)
- [Telemetry](./serving/samples/telemetry-go/README.md)
- [REST API sample](./serving/samples/rest-api-go/README.md)
- [All samples for serving](./serving/samples/)
- [All samples for eventing](./eventing/samples/)

### Logging and metrics

- [Installing logging, metrics and traces](./serving/installing-logging-metrics-traces.md)
- [Accessing logs](./serving/accessing-logs.md)
- [Accessing metrics](./serving/accessing-metrics.md)
- [Accessing traces](./serving/accessing-traces.md)
- [Setting up a logging plugin](./serving/setting-up-a-logging-plugin.md)

### Debugging

- [Debugging application issues](./serving/debugging-application-issues.md)
- [Debugging performance issues](./serving/debugging-performance-issues.md)
