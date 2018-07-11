# Welcome, Knative

Knative (pronounced /ˈnā-tiv/) extends Kubernetes to provide the
missing middleware that developers need to create modern,
source-centric, container-based, cloud-native applications.

Each of the components under the Knative project attempt to identify
common patterns and codify the best practices shared by successful
real-world Kubernetes-based frameworks and applications, such as:

- [Orchestrating source-to-container workflows on Kubernetes](build/README.md)
- [Deploying a container to Knative](install/getting-started-knative-app.md)
- [Updating your application on day 2 without an outage](serving/updating-existing-app.md)
- [Automatic scaling and sizing applications based on demand](serving/auto-scaling-with-knative.md)
- [Binding events to functions, apps, and containers with Knative](events/binding-events-with-knative.md)

Knative focuses on the "boring but difficult" parts that everyone
needs, but no one benefits from doing over again on their own. This in
turn frees application developers to spend more time writing
interesting code, not worrying about how they are going to build,
deploy, monitor, and debug it.

## Getting started with Knative

To get started using Knative, [pick a Kubernetes cluster of your choice](https://kubernetes.io/docs/setup/pick-right-solution/) and follow the
[Knative installation instructions](/install/Knative-with-GKE.md) to get the system up.

There are a [number of samples](serving/samples/README.md) that you can build and
run on your cluster once it's set up to help you get acquainted.

You can choose to install individual Knative components following the
instructions in each repo, or install a pre-built suite of components
by following the instructions for your platform:

- [Google Kubernetes Engine](install/Knative-with-GKE.md)
- [MiniKube](install/Knative-with-Minikube.md)

To deploy an app with Knative Serving, check out the
[Getting Started with Knative App Deployment guide](install/getting-started-knative-app.md).

## Who is Knative for

Knative was created with several personas in mind:

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

With a clear project scope, lightweight governance model and clean
lines of separation between pluggable components, the Knative project
establishes an efficient contributor workflow.

Knative is a diverse, open, and inclusive community. To get involved, see
[CONTRIBUTING.md](https://github.com/knative/docs/blob/master/community/CONTRIBUTING.md)
and join the [#community](https://knative.slack.com/messages/C92U2C59P/)
Slack channel.

Your own path to becoming a Knative contributor can
[begin anywhere](https://github.com/knative/serving/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22).
[Bug reports](https://github.com/knative/serving/issues/new) and
friction logs from new developers are especially welcome.

## What are the Knative components

The following Knative components are currently available:

- [Build](build/README.md) - Source to container build orchestration
- [Events](events/README.md) - Management and delivery of events
- [Serving](serving/README.md) - Scale to zero, request-driven compute
