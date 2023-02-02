<!-- Snippet used in the following topics:
- /docs/getting-started/quickstart-install.md
- /docs/install/quickstart-install.md
-->
## Install the Knative quickstart plugin

To get started, install the Knative `quickstart` plugin:

=== "Using Homebrew"

    Do one of the following:

    - To install the `quickstart` plugin by using [Homebrew](https://brew.sh){target=_blank}, run the command (Use `brew upgrade` instead if you are upgrading from a previous version):

        ```bash
        brew install knative-sandbox/kn-plugins/quickstart
        ```

=== "Using a binary"

    1. Download the binary for your system from the [`quickstart` release page](https://github.com/knative-sandbox/kn-plugin-quickstart/releases){target=_blank}.

    1. Rename the file to remove the OS and architecture information. For example, rename `kn-quickstart-amd64` to `kn-quickstart`.

    1. Make the plugin executable. For example, `chmod +x kn-quickstart`.

    1. Move the executable binary file to a directory on your `PATH` by running the command:

        ```bash
        mv kn-quickstart /usr/local/bin
        ```

    1. Verify that the plugin is working by running the command:

        ```bash
        kn quickstart --help
        ```

=== "Using Go"
    1. Check out the `kn-plugin-quickstart` repository:

          ```bash
          git clone https://github.com/knative-sandbox/kn-plugin-quickstart.git
          cd kn-plugin-quickstart/
          ```

    1. Build an executable binary:

          ```bash
          hack/build.sh
          ```

    1. Move the executable binary file to a directory on your `PATH`:

          ```bash
          mv kn-quickstart /usr/local/bin
          ```

     1. Verify that the plugin is working by running the command:

          ```bash
          kn quickstart --help
          ```

## Run the Knative quickstart plugin

The `quickstart` plugin completes the following functions:

1. **Checks if you have the selected Kubernetes instance installed**
1. **Creates a cluster called `knative`**
1. **Installs Knative Serving** with Kourier as the default networking layer, and sslip.io as the DNS
1. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation


To get a local deployment of Knative, run the `quickstart` plugin:

=== "Using kind"


    1. Install Knative and Kubernetes using [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) by running:
        ```bash
        kn quickstart kind
        ```

        !!! note
            Quickstart uses Port 80, and it will fail to install if any other services are bound on that port. If you have a service using Port 80, you'll need to stop it before using Quickstart.
            To check if another service is using Port 80:
            ```bash
            netstat -tnlp | grep 80
            ```

    1. After the plugin is finished, verify you have a cluster called `knative`:

        ```bash
        kind get clusters
        ```

=== "Using minikube"

    1. Install Knative and Kubernetes in a [minikube](https://minikube.sigs.k8s.io/docs/start/) instance by running:

        !!! note
            The minikube cluster will be created with 3&nbsp;GB of RAM. You can change to a
            different value not lower than 3&nbsp;GB by setting a memory config in minikube.
            For example,  `minikube config set memory 4096` will use 4&nbsp;GB of RAM.
        ```bash
        kn quickstart minikube
        ```

    1. The output of the previous command asked you to run minikube tunnel.
       Run the following command to start the process in a secondary terminal window, then return to the primary window and press enter to continue:
        ```bash
        minikube tunnel --profile knative
        ```
        The tunnel must continue to run in a terminal window any time you are using your Knative `quickstart` environment.

        The tunnel command is required because it allows your cluster to access Knative ingress service as a LoadBalancer from your host computer.

        !!! note
            To terminate the tunnel process and clean up network routes, enter `Ctrl-C`.
            For more information about the `minikube tunnel` command, see the [minikube documentation](https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-tunnel).

    1. After the plugin is finished, verify you have a cluster called `knative`:

        ```bash
        minikube profile list
        ```
