## Installation
> The startup script running on the right will: knative serving, knative networking layer
> and `kn` cli.
> the `quickstart` plugin and wait for kubernetes 
> to start. The `quickstart` plugin completes the following functions:

1. **Check kubernetes is up and running**.
1. **Install knative serving with Contour as the default networking layer**.
1. **Install knative `kn` cli**.

> Once you see a prompt, you can click on the command below, 
> it will be copied and run for you in the terminal on the right.
> This command will show you general information about your cluster.

`kubectl cluster-info`{{execute}}

**Expected output:**

`Kubernetes master is running at https://172.17.0.14:6443
KubeDNS is running at https://172.17.0.14:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.`

