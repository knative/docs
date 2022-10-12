## Prerequisites

Before installing Knative, you must meet the following prerequisites:

- **For prototyping purposes**, Knative works on most local deployments of Kubernetes. For example, you can use a local, one-node cluster that has 3&nbsp;CPUs and 4&nbsp;GB of memory.

    !!! tip
        You can install a local distribution of Knative for development purposes
        using the [Knative Quickstart plugin](/docs/getting-started/quickstart-install/)

- **For production purposes**, it is recommended that:

    - If you have only one node in your cluster, you need at least 6&nbsp;CPUs, 6&nbsp;GB of memory, and 30&nbsp;GB of disk storage.
    - If you have multiple nodes in your cluster, for each node you need at least 2&nbsp;CPUs, 4&nbsp;GB of memory, and 20&nbsp;GB of disk storage.
- You have a cluster that uses Kubernetes v1.23 or newer.
- You have installed the [`kubectl` CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- Your Kubernetes cluster must have access to the internet, because Kubernetes needs to be able to fetch images. To pull from a private registry, see [Deploying images from a private container registry](/docs/serving/deploying-from-private-registry/).

- **Verifying Images Signatures**, Knative releases from 1.8 onwards are signed with `cosign`

```
# install cosign and jq  if you don't have it

# download the yaml file, this example uses the serving manifest
curl -fsSLO https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-core.yaml
cat serving-core.yaml | grep 'gcr.io/' | awk '{print $2}' > images.txt
input=images.txt
while IFS= read -r image
do
  COSIGN_EXPERIMENTAL=1 cosign verify "$image" | jq
done < "$input"

kubectl apply -f serving-core.yaml
```

!!! note
    `COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed
    in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-nightly.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`

!!! caution
    The system requirements provided are recommendations only. The requirements for your installation might vary, depending on whether you use optional components, such as a networking layer.
