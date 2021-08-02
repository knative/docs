!!! todo "Installing the `kn` CLI"

    === "Using Homebrew"
        For macOS, you can install `kn` by using <a href="https://github.com/knative/homebrew-client" target="_blank">Homebrew</a>.

        ```
        brew install knative/client/kn
        ```

    === "Using a binary"

        You can install `kn` by downloading the executable binary for your system and placing it in the system path.

        1. Download the binary for your system from the <a href="https://github.com/knative/client/releases" target="_blank">`kn` release page</a>.

        1. Rename the binary, make it executable, and rename it to `kn`:

         ```
         mv kn-darwin-amd64 kn
         chmod +x kn
         ```

        (the original name will depend on your system architecture, i.e. `kn-darwin-amd64`, `kn-linux-amd64`, etc.)

     1. Move the executable binary file to a directory on your PATH:

         ```
         mv kn /usr/local/bin
         ```

     1. Verify that the plugin is working, for example:

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

        - <a href="https://gcr.io/knative-releases/knative.dev/client/cmd/kn" target="_blank">Latest release</a>

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
