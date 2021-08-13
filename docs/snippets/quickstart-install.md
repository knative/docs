!!! todo "Installing the `quickstart` plugin"
    === "Using Homebrew"
        For macOS, you can install the `quickstart` plugin by using <a href="https://brew.sh" target="_blank">Homebrew</a>.
            ```
            brew install knative-sandbox/kn-plugins/quickstart
            ```

    === "Using a binary"
         You can install the `quickstart` plugin by downloading the executable binary for your system and placing it in the `~/.config/kn/plugins` directory.

         A link to the latest stable binary release is available on the <a href="https://github.com/knative-sandbox/kn-plugin-quickstart/releases"> `quickstart` release page</a>.

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

        1. Move the executable binary file to the `kn` plugins directory:

             ```
             mkdir -p ~/.config/kn/plugins
             mv kn-quickstart ~/.config/kn/plugins
             ```

         1. Verify that the plugin is working, for example:

             ```
             kn quickstart --help
             ```

The `quickstart` plugin completes the following functions:

1. **Checks if you have [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} installed,** and creates a cluster called `knative`.
1. **Installs Knative Serving with Kourier** as the default networking layer, and nip.io as the DNS.
1. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation.

!!! todo "Install Knative and Kubernetes on a local Docker Daemon using `kn quickstart`"
    ```bash
    kn quickstart kind
    ```

??? bug "Having issues with Kind?"
    We've found that some users (specifically Linux) may have trouble with Docker and, subsequently, Kind. Though this tutorial assumes you have Kind installed, you can easily follow along with a different installation.

    We have provide an alternative Quickstart on `minikube` here: [https://github.com/csantanapr/knative-minikube](https://github.com/csantanapr/knative-minikube){_target="_blank"}

Installing may take a few minutes. After the plugin is finished, check to make sure you have a Cluster called `knative`
!!! success "Verify Installation"
    ```bash
    kind get clusters
    ```
