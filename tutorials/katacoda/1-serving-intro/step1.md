## Installation
> The startup script running on the right will install the `kn` cli, the `quickstart` plugin and wait for kubernetes 
> to start. The `quickstart` plugin completes the following functions:

1. **Checks if you have the selected Kubernetes instance installed**.
2. **Creates a cluster called `knative`**
3. **Installs Knative Serving** with Kourier as the default networking layer, and sslip.io as the DNS.
4. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation.

> Once you see a prompt, you can click on the command below, and verify you have a cluster called `knative`, and they 
> will be copied and run for you in the terminal on the right.

`kind get clusters`{{execute}}
