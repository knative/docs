---
title: "Deploying images from a private container registry"
linkTitle: "Deploying from private registries"
weight: 10
type: "docs"
---

Learn how to configure your Knative cluster to deploy images from a private 
container registry.

To enable access to your private container images, you create a `imagePullSecret` type 
Kubernetes secret with your credentials, add that secret to your default
[service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/),
and then deploy those configurations to your Knative cluster.

## Before you begin

Ensure that you have the following setup and running:

- Knative Serving. [Learn about installing Knative](../../install/README.md)
- You must have access to and the credentials to the private container registry 
  where your container image is stored.

## Configuring your credentials in Knative

1. Create a `imagePullSecret` type secret named `container-registry` that contains 
   your credentials:

    ```shell
    kubectl create secret container-registry \
      --docker-server=[PRIVATE_REGISTRY_SERVER_URL] \
      --docker-email=[PRIVATE_REGISTRY_EMAIL] \
      --docker-username=[PRIVATE_REGISTRY_USER] \
      --docker-password=[PRIVATE_REGISTRY_PASSWORD]
    ```

    Where
    - `[PRIVATE_REGISTRY_SERVER_URL]` is the URL to the private
      registry where your container image is stored. 
       
       Examples:
       - Google Container Registry: [https://gcr.io/](https://gcr.io/)
       - DockerHub [https://index.docker.io/v1/](https://index.docker.io/v1/)
       
    * `[PRIVATE_REGISTRY_EMAIL]` is your email address that is associated with
      the private registry.
      
    * `[PRIVATE_REGISTRY_USER]` is your container registry username.

       Tip: 
       If you're using GCR and prefer to store and pull
       long-lived credentials instead of passing short-lived access tokens, see
       [Authentication methods: JSON key file](/container-registry/docs/advanced-authentication#json_key_file).
       
    * `[PRIVATE_REGISTRY_PASSWORD]` is your container registry password.

1. Add the `container-registry` secret to your `default` service account in the
   `default` namespace.
   
    Note: By default, the `default` service account in each of the 
    [namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) 
    of your Knative cluster are use by your revisions unless 
    [`serviceAccountName`](../spec/knative-api-specification-1.0.md) is specified.

   1. Run the following command to edit your `default` service account:
   
       ```shell
       kubectl edit serviceaccount default --namespace default
       ```

   1. Add the `container-registry` secret under the `imagePullSecrets` element in 
      your `default` service account:

       ```
       imagePullSecrets:
       - name: container-registry
       ```

      Example:
       
       ```yaml
       apiVersion: v1
       kind: ServiceAccount
       metadata:
         name: default
         namespace: default
         ...
       secrets:
       - name: default-token-zd84v
       imagePullSecrets:
       - name: container-registry
       ```

1. Apply the service account to your Knative cluster:

   ```bash
   kubectl apply --filename service-account.yaml
   ```
Now, all the new pods that are created in the `default` namespace will include
your credentials and have access to your container images in the private registry.

## What's next

You can now create a service that uses your container images from the private registry. 
[Learn how to create a Knative service](../getting-started-knative-app.md)
