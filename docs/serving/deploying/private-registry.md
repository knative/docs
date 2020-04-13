---
title: "Deploying images from a private container registry"
linkTitle: "Deploying from private registries"
weight: 10
type: "docs"
---

Learn how to configure your Knative cluster to deploy images from a private 
container registry.

To share access to your private container images across multiple services and 
revisions, you create a list of Kubernetes secrets
([`imagePullSecrets`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/#pod-v1-core))
using your registry credentials, add that `imagePullSecrets` to your default
[service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/),
and then deploy those configurations to your Knative cluster.

## Before you begin

You need:

- A Kubernetes cluster with [Knative Serving installed](../../install/README.md).
- The credentials to the private container registry where your container images are stored.

## Configuring your credentials in Knative

1. Create a `imagePullSecrets` that contains your credentials as a list of secrets:

    ```shell
    kubectl create secret docker-registry [REGISTRY-CRED-SECRETS] \
      --docker-server=[PRIVATE_REGISTRY_SERVER_URL] \
      --docker-email=[PRIVATE_REGISTRY_EMAIL] \
      --docker-username=[PRIVATE_REGISTRY_USER] \
      --docker-password=[PRIVATE_REGISTRY_PASSWORD]
    ```

    Where
    - `[REGISTRY-CRED-SECRETS]` is the name that you want for your secrets
      (`imagePullSecrets` object). For example, `container-registry`.

    - `[PRIVATE_REGISTRY_SERVER_URL]` is the URL to the private
      registry where your container images are stored. 

       Examples:
       - Google Container Registry: [https://gcr.io/](https://gcr.io/)
       - DockerHub [https://index.docker.io/v1/](https://index.docker.io/v1/)

    * `[PRIVATE_REGISTRY_EMAIL]` is your email address that is associated with
      the private registry.

    * `[PRIVATE_REGISTRY_USER]` is the username that you use to access the
      private container registry.

    * `[PRIVATE_REGISTRY_PASSWORD]` is the password that you use to access
      the private container registry.
    
     Example:
     
    ```shell
    kubectl create secret `container-registry` \
      --docker-server=https://gcr.io/ \
      --docker-email=my-account-email@address.com \
      --docker-username=my-grc-username \
      --docker-password=my-gcr-password
    ```
     
    Tip: After creating the `imagePullSecrets`, you can view those secret's by running:
    
    ```shell
    kubectl get secret [REGISTRY-CRED-SECRETS] --output=yaml
    ```

1. Add the `imagePullSecrets` to your `default` service account in the
   `default` namespace.
   
    Note: By default, the `default` service account in each of the 
    [namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) 
    of your Knative cluster are use by your revisions unless 
    [`serviceAccountName`](../spec/knative-api-specification-1.0.md) is specified.

   1. Run the following command to modify your `default` service account:
   
      For example, if you named your secrets `container-registry`, then you
	  patch it with this.

       ```shell
       kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"container-registry\"}]}"
       ```

1. Deploy the updated service account to your Knative cluster:

    ```bash
   kubectl apply --filename service-account.yaml
   ```

Now, all the new pods that are created in the `default` namespace will include
your credentials and have access to your container images in the private registry.

## What's next

You can now create a service that uses your container images from the private registry. 
[Learn how to create a Knative service](../getting-started-knative-app.md).
