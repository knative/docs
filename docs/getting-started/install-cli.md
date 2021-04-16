# Installing the Knative CLI

## (Recommended) `kn`

**The Knative CLI provides a quick and easy interface for creating Knative resources** such as Knative Services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.



!!! example "Installing the `kn` CLI"

    === "Using Homebrew"
        For macOS, you can install `kn` by using <a href="https://github.com/knative/homebrew-client" target="_blank">Homebrew</a>.

        ```
        brew install knative/client/kn
        ```

    === "Using a binary"

        You can install `kn` by downloading the executable binary for your system and placing it in the system path.

        A link to the latest stable binary release is available on the <a href="https://github.com/knative/client/releases" target="_blank">`kn` release page</a>.

    === "Installing kn using Go"

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

    === "Running kn using container images"

        **WARNING:** Nightly container images include features which may not be included in the latest Knative release and are not considered to be stable.

        Links to images are available here:

        - <a href="https://gcr.io/knative-releases/knative.dev/client/cmd/kn" target="_blank">Latest release</a>
        - <a href="https://gcr.io/knative-nightly/knative.dev/client/cmd/kn" target="_blank">Nightly container image</a>

        You can run `kn` from a container image. For example:

        ```
        docker run --rm -v "$HOME/.kube/config:/root/.kube/config" gcr.io/knative-releases/knative.dev/client/cmd/kn:latest service list
        ```

        **NOTE:** Running `kn` from a container image does not place the binary on a permanent path. This procedure must be repeated each time you want to use `kn`.
!!! tip
    For more complex installations, such as nightly releases, see [Install `kn`](../client/install-kn.md)
