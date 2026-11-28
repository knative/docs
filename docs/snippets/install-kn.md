<!-- Snippet used in the following topics:
- versioned/client/install-kn.md
- versioned/getting-started/quickstart-install.md
- versioned/install/quickstart-install.md
-->

## Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources, such as Knative Services and Event Sources, without the need to create or modify YAML files directly.

The `kn` CLI also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

Install `kn` on your local machine so you can run it directly and use plugins
such as `quickstart`.

=== "Using Homebrew"

    Do one of the following:

    - To install `kn` by using [Homebrew](https://brew.sh){target=_blank}, run the command (Use `brew upgrade` instead if you are upgrading from a previous version):

        ```bash
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

    1. Move the executable binary file to a directory on your `PATH` by running the command:

        ```bash
        mv kn /usr/local/bin
        ```

    1. Verify that `kn` commands are working properly. For example:

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

    1. Move the executable binary file to a directory on your `PATH` by running the command:

        ```bash
        mv kn /usr/local/bin
        ```

    1. Verify that `kn` commands are working properly. For example:

        ```bash
        kn version
        ```
