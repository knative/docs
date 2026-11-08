<!-- Snippet used in the following topics:
- versioned/functions/about-functions.md
- versioned/getting-started/about-knative-functions.md
- versioned/README.md
-->
Knative Functions provides a simple programming model for using functions on Knative, without requiring in-depth knowledge of Knative, Kubernetes, containers, or dockerfiles.

Knative Functions enables you to easily create, build, and deploy [stateless](https://www.techtarget.com/whatis/definition/stateless-app){target=_blank}, [event-driven](https://en.wikipedia.org/wiki/Event-driven_programming){target=_blank} functions as Knative Services by using the `func` CLI.

For containerized workflows, `func` builds an [Open Container Initiative (OCI) format](https://opencontainers.org/about/overview/){target=_blank} image for you. Local builds and runs do not publish that image to a registry by default. Deployment normally builds the image when necessary, publishes it to your configured registry, and creates or updates a Knative Service.

You can create functions and manage function workflows by using the `func` CLI, or by using the `kn func` plugin for the Knative CLI.
