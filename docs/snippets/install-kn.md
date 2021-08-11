!!! todo "Installing the `kn` CLI"

    === "Using Homebrew"
        For macOS, you can install `kn` by using [Homebrew](https://brew.sh"){target=_blank}.

        ```
        brew install knative/client/kn
        ```

    === "Using a binary"

        You can install `kn` by downloading the executable binary for your system and placing it in the system path.

        1. Download the binary for your system from the [`kn` release page](https://github.com/knative/client/releases){target=_blank}.

        1. Rename the binary to `kn` and make it executable by running the commands:

            ```
            mv <path-to-binary-file> kn
            chmod +x kn
            ```

            Where `<path-to-binary-file>` is the path to the binary file you downloaded in the previous step, for example, `kn-darwin-amd64` or `kn-linux-amd64`.

        1. Move the executable binary file to a directory on your PATH by running the command:

            ```
            mv kn /usr/local/bin
            ```

        1. Verify that the plugin is working by running the command:

            ```
            kn version
            ```

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

        Links to images are available here:

        - [Latest release](https://gcr.io/knative-releases/knative.dev/client/cmd/kn){target=_blank}

        You can run `kn` from a container image. For example:

        ```
        docker run --rm -v "$HOME/.kube/config:/root/.kube/config" gcr.io/knative-releases/knative.dev/client/cmd/kn:latest service list
        ```

        !!! note
            Running `kn` from a container image does not place the binary on a permanent path. This procedure must be repeated each time you want to use `kn`.

??? bug "Having issues upgrading `kn`?"

    If you are having issues upgrading using Homebrew, it may be due to a change to a `CLI` repository, where `master` branch was renamed to `main`. If so, run

    ```
    brew tap --repair
    brew update
    brew upgrade kn
    ```

    to resolve the issue.
