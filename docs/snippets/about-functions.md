<!-- Snippet used in the following topics:
- /docs/functions/README.md
-->
Knative Functions provides a simple programming model for using functions on Knative, without requiring in-depth knowledge of Knative, Kubernetes, containers, or dockerfiles.

Knative Functions enables you to easily create, build, and deploy stateless, event-driven functions as Knative Services by using the `func` CLI.

When you build or run a function, an [Open Container Initiative (OCI) format](https://opencontainers.org/about/overview/){target=_blank} container image is generated automatically for you, and is stored in a container registry. Each time you update your code and then run or deploy it, the container image is also updated.

You can create functions and manage function workflows by using the `func` CLI, or by using the `kn func` plugin for the Knative CLI.
