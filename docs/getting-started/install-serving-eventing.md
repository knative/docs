# Install Knative components

## Install Knative using the konk script

You can get started with a local deployment of Knative by using _Knative on Kind_ (`konk`):

!!! todo "Install Knative and Kubernetes on a local Docker Daemon using `konk`"
    ```
    curl -sL install.konk.dev | bash
    ```

`konk` is a shell script that completes the following functions:

1. Checks if you have `kind` installed, and creates a cluster called `knative`.
1. Installs Knative Serving with Kourier as the default networking layer, and nip.io as the DNS.
1. Installs Knative Eventing and creates a default broker and channel implementation.

## Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources such as Knative services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.


!!! todo "Installing the `kn` CLI"

    === "Using Homebrew"
        For macOS, you can install `kn` by using <a href="https://github.com/knative/homebrew-client" target="_blank">Homebrew</a>.

        ```
        brew install knative/client/kn
        ```

    === "Using a binary"

        You can install `kn` by downloading the executable binary for your system and placing it in the system path.

        A link to the latest stable binary release is available on the <a href="https://github.com/knative/client/releases" target="_blank">`kn` release page</a>.

    === "Using Go"

        1. Check out the `kn` client repository:

              ```
              git clone https://github.com/knative/client.git
              cd client/
              ```

        1. Build an executable binary:

              ```
              hack/build.sh -f
              ```

        1. Move `kn` into your system path, and verify that `kn` commands are working properly. For example:

              ```
              kn version
              ```

    === "Using a container image"

        **WARNING:** Nightly container images include features which may not be included in the latest Knative release and are not considered to be stable.

        Links to images are available here:

        - <a href="https://gcr.io/knative-releases/knative.dev/client/cmd/kn" target="_blank">Latest release</a>
        - <a href="https://gcr.io/knative-nightly/knative.dev/client/cmd/kn" target="_blank">Nightly container image</a>

        You can run `kn` from a container image. For example:

        ```
        docker run --rm -v "$HOME/.kube/config:/root/.kube/config" gcr.io/knative-releases/knative.dev/client/cmd/kn:latest service list
        ```

        **NOTE:** Running `kn` from a container image does not place the binary on a permanent path. This procedure must be repeated each time you want to use `kn`.

    For more complex installations, such as nightly releases, see [Install `kn`](../client/install-kn.md)
