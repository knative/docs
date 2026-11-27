<!-- Snippet used in the following topics:
- versioned/functions/README.md
- versioned/README.md
-->
Knative Functions provides a simple programming model for using functions on Knative, without requiring in-depth knowledge of Knative, Kubernetes, containers, or dockerfiles.

Knative Functions enables you to easily create, build, and deploy [stateless](https://www.techtarget.com/whatis/definition/stateless-app){target=_blank}, [event-driven](https://en.wikipedia.org/wiki/Event-driven_programming){target=_blank} functions as Knative Services by using the `func` CLI.

Functions can be packaged as [Open Container Initiative (OCI) images](https://opencontainers.org/about/overview/){target=_blank} without writing a Dockerfile. A local container build does not publish an image to a registry. Deployment builds and pushes an image so the cluster can pull it. Supported host builders can also run functions locally without a container.

You can create functions and manage function workflows by using the `func` CLI, or by using the `kn func` plugin for the Knative CLI.
