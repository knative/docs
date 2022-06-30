<!-- Snippet used in the following topics:
- /docs/client/install-kn.md
- /docs/getting-started/quickstart-install.md
- docs/install/quickstart-install.md
-->

## Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources, such as Knative Services and Event Sources, without the need to create or modify YAML files directly.

The `kn` CLI also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

=== "Using Homebrew"

    Do one of the following:

    - To install `kn` by using [Homebrew](https://brew.sh){target=_blank}, run the command (Use `brew upgrade` instead if you are upgrading from a previous version):

        ```bash
        brew install knative/client/kn
        ```

        ??? bug "Having issues upgrading `kn` using Homebrew?"

            If you are having issues upgrading using Homebrew, it might be due to a change to a CLI repository where the `master` branch was renamed to `main`. Resolve this issue by running the command:

            ```bash
            brew uninstall kn
            brew untap knative/client --force
            brew install knative/client/kn
            ```

=== "Using a binary"

    You can install `kn` by downloading the executable binary for your system and placing it in the system path.

    1. Download the binary for your system from the [`kn` release page](https://github.com/knative/client/releases){target=_blank}.

    1. Rename the binary to `kn` and make it executable by running the commands:

        ```bash
        mv <path-to-binary-file> kn
        chmod +x kn
        ```

        Where `<path-to-binary-file>` is the path to the binary file you downloaded in the previous step, for example, `kn-darwin-amd64` or `kn-linux-amd64`.

    1. Move the executable binary file to a directory on your PATH by running the command:

        ```bash
        mv kn /usr/local/bin
        ```

    1. Verify that the plugin is working by running the command:

        ```bash
        kn version
        ```

=== "Using Go"

    1. Check out the `kn` client repository:

          ```bash
          git clone https://github.com/knative/client.git
          cd client/
          ```

    1. Build an executable binary:

          ```bash
          hack/build.sh -f
          ```

    1. Move `kn` into your system path, and verify that `kn` commands are working properly. For example:

          ```bash
          kn version
          ```

=== "Using a container image"

    Links to images are available here:

    - [Latest release](https://gcr.io/knative-releases/knative.dev/client/cmd/kn){target=_blank}

    You can run `kn` from a container image. For example:

    ```bash
    docker run --rm -v "$HOME/.kube/config:/root/.kube/config" gcr.io/knative-releases/knative.dev/client/cmd/kn:latest service list
    ```

    !!! note
        Running `kn` from a container image does not place the binary on a permanent path. This procedure must be repeated each time you want to use `kn`.
