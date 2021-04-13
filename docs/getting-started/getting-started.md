# Installing Knative with KonK (Knative on Kind)
**The fastest way to get started with Knative locally** is to use the <a href= "https://konk.dev" target="blank_">Konk (Knative-on-kind) script.</a>

This script installs a local Knative deployment on your local machine's `Docker` daemon using [Kind](https://kind.sigs.k8s.io/).

### Prerequisites
- You will need to have [Docker installed.](https://docs.docker.com/get-docker/)
- You will need to have [Kind installed.](https://kind.sigs.k8s.io/docs/user/quick-start/)

!!! success "Install Knative and Kubernetes on a local Docker Daemon using Konk"
    ```
    curl -sL install.konk.dev | bash
    ```

??? question "Need to upgrade Kind?""
    ```
    brew upgrade kind
    ```
## Other Installation Options
  - If you would like to customize the Knative installation or install it on a remote cluster, start by [Checking the Pre-Requisites](./install/prerequisites.md) then come back here to finish the remaining steps!

!!! warning
    You will need `networking layer` and `DNS` for Knative Serving as well as a `broker` for Knative Eventing if you want to follow this tutorial. 
