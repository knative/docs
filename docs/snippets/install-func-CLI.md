<!-- Snippet used in the following topics:
- /docs/functions/install-func.md
- /docs/getting-started/install-func.md
-->
=== "Homebrew"

    To install `func` using Homebrew, run the following commands:

    ```bash
    brew tap knative-sandbox/kn-plugins
    ```

    ```bash
    brew install func
    ```

    If you have already installed the `kn` CLI by using Homebrew, the `func` CLI is automatically recognized as a plugin to `kn`, and can be referenced as `kn func` or `func` interchangeably.

    !!! note
        Use `brew upgrade` instead if you are upgrading from a previous version.

=== "Executable binary"

    You can install `func` by downloading the executable binary for your system and placing it in the system path.

    1. Download the binary for your system from the [`func` release page](https://github.com/knative/func/releases){target=_blank}.

    1. Rename the binary to `func` and make it executable by running the following commands:

        ```bash
        mv <path-to-binary-file> func
        ```

        ```bash
        chmod +x func
        ```

        Where `<path-to-binary-file>` is the path to the binary file you downloaded in the previous step, for example, `func_darwin_amd64` or `func_linux_amd64`.

    1. Move the executable binary file to a directory on your PATH by running the command:

        ```bash
        mv func /usr/local/bin
        ```

    1. Verify that the CLI is working by running the command:

        ```bash
        func version
        ```

=== "Go"

    1. Check out the `func` client repository and navigate to the `func` directory:

        ```bash
        git clone https://github.com/knative/func.git func
        ```

        ```bash
        cd func/
        ```

    1. Build an executable binary:

        ```bash
        make
        ```

    1. Move `func` into your system path, and verify that `func` commands are working properly. For example:

        ```bash
        func version
        ```

=== "Container image"

    Run `func` from a container image. For example:

    ```bash
    docker run --rm -it ghcr.io/knative/func/func create -l node -t http myfunc
    ```

    Links to images are available here:

    - [Latest release](https://gcr.io/knative-releases/knative.dev/client/cmd/kn){target=_blank}

    !!! note
        Running `func` from a container image does not place the binary on a permanent path. This procedure must be repeated each time you want to use `func`.

<!--TODO: Maybe needs an update when https://github.com/knative/func/issues/1308 is fixed-->
