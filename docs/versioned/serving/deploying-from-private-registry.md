---
audience: developer
components:
  - serving
function: how-to
---

# Deploying images from a private container registry

You can configure your Knative cluster to deploy images from a private registry across multiple Services and Revisions. To do this, you must create a list of Kubernetes secrets ([`imagePullSecrets`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)) by using your registry credentials. You must then add those secrets to the default [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) for all Services, or the Revision template for a single Service.

## Prerequisites

- You must have a Kubernetes cluster with Knative Serving installed.
- You must have access to credentials for the private container registry where your container images are stored.

## Procedure

1. Create a `docker-registry` Secret in your target namespace. If your local `$HOME/.docker/config.json` stores direct registry credentials (rather than a host `credsStore` helper), you can create the Secret from that file:

    ```bash
    kubectl create secret generic <registry-credential-secret> \
      --namespace <namespace> \
      --from-file=.dockerconfigjson="$HOME/.docker/config.json" \
      --type=kubernetes.io/dockerconfigjson
    ```

    If your Docker configuration uses a credential helper (`credsStore`), follow [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) in the Kubernetes documentation to create a `docker-registry` Secret instead.

1. Choose one of the following to attach the Secret:

    - **Single Service (recommended):** reference `imagePullSecrets` on the Service's Revision template (replace `<private-registry>/<repo>:<tag>` with your private image):

        ```yaml
        apiVersion: serving.knative.dev/v1
        kind: Service
        metadata:
          name: private-app
          namespace: <namespace>
        spec:
          template:
            spec:
              imagePullSecrets:
                - name: <registry-credential-secret>
              containers:
                - image: <private-registry>/<repo>:<tag>
                  ports:
                    - containerPort: 8080
        ```

    - **All Services in a namespace:** patch the `default` ServiceAccount in that namespace so every Revision uses the Secret unless `serviceAccountName` is overridden:

        ```bash
        kubectl patch serviceaccount default \
          --namespace <namespace> \
          -p '{"imagePullSecrets": [{"name": "<registry-credential-secret>"}]}'
        ```

1. Apply the Service and verify it becomes ready and resolves the image digest on its latest Revision:

    ```bash
    kubectl apply -f private-app.yaml
    kubectl wait kservice/private-app --namespace <namespace> --for=condition=Ready --timeout=120s
    REVISION=$(kubectl get kservice private-app --namespace <namespace> -o jsonpath='{.status.latestReadyRevisionName}')
    kubectl get revision "$REVISION" --namespace <namespace> -o jsonpath='{.status.containerStatuses[0].imageDigest}'; echo
    ```

If your private registry uses a custom CA certificate or sits behind a corporate proxy, your cluster administrator must also configure [Registry trust and tag resolution](tag-resolution.md).
