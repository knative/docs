!!! todo "Installing the `quickstart` plugin"
    === "Using Homebrew"
        For macOS, you can install the `quickstart` plugin by using [Homebrew](https://brew.sh){target=_blank}.
            ```
            brew install knative-sandbox/kn-plugins/quickstart
            ```

    === "Using a binary"
         You can install the `quickstart` plugin by downloading the executable binary for your system and placing it on your `PATH` (for example, in `/usr/local/bin`).

         A link to the latest stable binary release is available on the [`quickstart` release page](https://github.com/knative-sandbox/kn-plugin-quickstart/releases){target=_blank}.

    === "Using Go"
        1. Check out the `kn-plugin-quickstart` repository:

              ```
              git clone https://github.com/knative-sandbox/kn-plugin-quickstart.git
              cd kn-plugin-quickstart/
              ```

        1. Build an executable binary:

              ```
              hack/build.sh
              ```

        1. Move the executable binary file to a directory on your `PATH`:

             ```
             mv kn-quickstart /usr/local/bin
             ```

         1. Verify that the plugin is working, for example:

             ```
             kn quickstart --help
             ```

The `quickstart` plugin completes the following functions:

1. **Checks if you have the selected Kubernetes instance installed,** and creates a cluster called `knative`.
2. **Installs Knative Serving with Kourier** as the default networking layer, and nip.io as the DNS.
3. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation.


!!! todo "Install Knative and Kubernetes locally"
    === "Using kind"

        Install Knative and Kubernetes on a local Docker daemon by running:
        ```bash
        kn quickstart kind
        ```

        After the plugin is finished, verify you have a cluster called `knative`:
        ```bash
        kind get clusters
        ```

    === "Using minikube"

        Install Knative and Kubernetes in a minikube instance by running:
        ```bash
        kn quickstart minikube
        ```

        After the plugin is finished, verify you have a cluster called `knative`:
        ```bash
        minikube profile list
        ```


