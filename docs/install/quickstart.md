The fastest way to get started with knative locally is to use the <a href= "https://konk.dev" target="blank_">Konk (Knative-on-kind) script.</a>

This script installs a local knative installation on your local machine's `Docker` daemon using [Kind](https://kind.sigs.k8s.io/). You will need to have Docker installed.

!!! success "Install Knative and Kubernetes on a local Docker Daemon using Konk"
    ```
    curl -sL get.konk.dev | bash
    ```

## Next Steps

 - If you would like to customize the Knative installation or install it on a remote cluster, start by [Checking the Pre-Requisites](./prerequisites.md).
 - Now that you've installed Knative, get started with [Serving](../serving/README.md) or [Eventing](../eventing/README.md).
