# Deploying images from a private container registry

You can share access to private container images across multiple Services and Revisions by configuring your Knative cluster to deploy images from a private
container registry.

To configure using a private container registry, you must:

1. Create a list of Kubernetes secrets ([`imagePullSecrets`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#pod-v1-core)) by using your registry credentials.
1. Add those `imagePullSecrets` to the default [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).
1. Deploy those configurations to your Knative cluster.

## Prerequisites

- You must have a Kubernetes cluster with Knative Serving installed.
- You must have access to credentials for the private container registry where your container images are stored.

## Procedure

1. Create a `imagePullSecrets` object that contains your credentials as a list of secrets:

    ```bash
    kubectl create secret docker-registry <registry-credential-secrets> \
      --docker-server=<private-registry-url> \
      --docker-email=<private-registry-email> \
      --docker-username=<private-registry-user> \
      --docker-password=<private-registry-password>
    ```

    Where:

    - `<registry-credential-secrets>` is the name that you want to use for your secrets (the `imagePullSecrets` object). For example, `container-registry`.

    - `<private-registry-url>` is the URL of the private registry where your container images are stored. Examples include [Google Container Registry](https://gcr.io/) or [DockerHub](https://docker.io/).

    * `<private-registry-email>` is the email address that is associated with
      the private registry.

    * `<private-registry-user>` is the username that you use to access the
      private container registry.

    * `<private-registry-password>` is the password that you use to access
      the private container registry.

    Example:

    ```bash
    kubectl create secret container-registry \
      --docker-server=https://gcr.io/ \
      --docker-email=my-account-email@address.com \
      --docker-username=my-grc-username \
      --docker-password=my-gcr-password
    ```

    !!! tip
        After you have created the `imagePullSecrets` object, you can view the secrets by running:

        ```bash
        kubectl get secret <registry-credential-secrets> -o=yaml
        ```

1. Add the `imagePullSecrets` to the `default` service account in the `default` namespace.

    !!! note
        By default, the `default` service account in each of the [namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) of your Knative cluster are used by your Revisions, unless the [`serviceAccountName`](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#revision-2) is specified.

    For example, if have you named your secrets `container-registry`, you can run the following command to modify the `default` service account:

    ```bash
    kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"container-registry\"}]}"
    ```

    New pods that are created in the `default` namespace now include your credentials and have access to your container images in the private registry.
