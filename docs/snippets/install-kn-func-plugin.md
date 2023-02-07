<!-- Snippet used in the following topics:
- /docs/functions/install-func.md
- /docs/getting-started/install-func.md
-->
=== "kn plugin"

    You can install Knative Functions as a `kn` CLI plugin, by downloading the executable binary for your system and placing it in the system path.

    1. Download the binary for your system from the [`func` release page](https://github.com/knative/func/releases){target=_blank}.

    1. Rename the binary to `kn-func`, and make it executable by running the following commands:

        ```bash
        mv <path-to-binary-file> kn-func
        ```

        ```bash
        chmod +x kn-func
        ```

        Where `<path-to-binary-file>` is the path to the binary file you downloaded in the previous step, for example, `func_darwin_amd64` or `func_linux_amd64`.

    1. Move the executable binary file to a directory on your PATH by running the command:

        ```bash
        mv kn-func /usr/local/bin
        ```

    1. Verify that the CLI is working by running the command:

        ```bash
        kn func version
        ```
