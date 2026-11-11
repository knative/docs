---
audience: developer
components:
  - serving
function: how-to
---

<span id="creating-a-service"></span>

# Deploy an HTTP container as a Knative Service

Deploy an existing container image as a **new** Knative Service, then verify readiness and an HTTP response. Choose YAML or the `kn` CLI for creation; both routes use the same verification steps. This guide does not build an image, replace an existing Deployment, or switch traffic from another application.

## Prerequisites

- A Kubernetes cluster with Knative Serving and its networking layer installed. See [Installing Knative Serving](../../install/yaml-install/serving/install-serving-with-yaml.md) if you need a cluster installation.
- `kubectl`, a kubeconfig for the intended cluster, and an existing namespace in which you can create Knative Services, get/list/watch them for verification, and list Kubernetes Services for the name check. The optional CLI route requires [installing `kn`](../../client/install-kn.md).
- An image in a registry accessible to the cluster, with any required pull credentials configured in the selected namespace. For private images, follow [Deploying images from a private registry](../deploying-from-private-registry.md) first and include the required pull-secret or ServiceAccount configuration in your Service. The public sample below needs no registry credentials.
- An HTTP application that listens on the container port you configure. Serving supplies that port through the `PORT` environment variable, but setting `containerPort` or `--port` does not reconfigure an application that ignores `PORT`. For an image that always listens on port `80`, configure port `80`, not the sample's `8080`. See the [runtime contract](https://github.com/knative/specs/blob/main/specs/serving/runtime-contract.md#protocols-and-ports){target=_blank} and the [v1.24 container construction](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/reconciler/revision/resources/deploy.go#L292-L324){target=_blank}, which selects the port and supplies `PORT`.
- Any application-specific environment variables, Secrets, and other dependencies are available. Do not rely on local container state surviving replica replacement; review the [Deployment mapping considerations](../convert-deployment-to-knative-service.md#determine-if-your-workload-is-a-good-fit-for-knative) for an existing workload.
- Network and DNS access from your terminal to the Service URL, and a GET endpoint whose expected response you know. For an endpoint requiring authentication, adapt the request to your application's authentication requirements.

## Procedure

### Select the destination and image

Set these values in the shell you will use for creation and verification:

```bash
CONTEXT=my-cluster-context
NAMESPACE=default
SERVICE=helloworld-go
IMAGE=ghcr.io/knative/helloworld-go:latest
CONTAINER_PORT=8080
REQUEST_PATH=/
```

Replace the context and namespace with your intended destination. For your own container, replace the Service name, image, port, and request path. The supplied image is a public hello-world example. Choose a name not already used by a Knative Service or a Kubernetes Service in this namespace; this task creates a new application rather than updating one.

Check the context list and the two Service resource types before creation:

```bash
kubectl config get-contexts
kubectl --context "$CONTEXT" get services.serving.knative.dev -n "$NAMESPACE"
kubectl --context "$CONTEXT" get services -n "$NAMESPACE"
```

Confirm that the named context is the intended cluster and neither list contains your chosen name. If access fails, resolve the connection or permissions before proceeding; see [Connect CLI tools to a cluster](../../client/connect-to-cluster.md). All resource commands below select the context and namespace explicitly and do not change your kubeconfig defaults.

### Create the Service

=== "Apply YAML"

    1. Save this example as `service.yaml`:

        ```yaml
        apiVersion: serving.knative.dev/v1
        kind: Service
        metadata:
          name: helloworld-go
        spec:
          template:
            spec:
              containers:
                - image: ghcr.io/knative/helloworld-go:latest
                  ports:
                    - containerPort: 8080
                  env:
                    - name: TARGET
                      value: "Go Sample v1"
        ```

        For your application, edit the manifest's name, image, port, and environment settings. The manifest name must match `SERVICE` above. Shell variables are **not** automatically substituted into this file. The sample's `TARGET` variable is specific to hello-world; remove or replace it for your image. Add private-registry configuration here if required.

        The manifest omits `metadata.namespace`; the command selects `NAMESPACE`. If you add a namespace to the manifest, it must match that selected namespace.

    2. Create the new resource:

        ```bash
        kubectl --context "$CONTEXT" create -n "$NAMESPACE" -f service.yaml
        ```

        This deliberately uses `create`, which fails if the Knative Service already exists, rather than applying an update to an existing Service. If the name is in use, choose another name and update both the manifest and `SERVICE` before retrying.

=== "kn CLI"

    Create the Service from the selected image and port:

    ```bash
    kn service create "$SERVICE" --context "$CONTEXT" --namespace "$NAMESPACE" \
      --image "$IMAGE" --port "$CONTAINER_PORT" --env "TARGET=Go Sample v1"
    ```

    Remove or replace the sample-specific `--env` argument for your application. Include any private-registry configuration required for your Service; consult the [`kn` command reference]({{ clientdocs() }}){target=_blank} for supported creation options. Do not add `--force`: this task is for a new Service, not replacement of an existing one.

## Verify readiness and a response

1. Wait for the new Service to become Ready:

    ```bash
    kubectl --context "$CONTEXT" wait service.serving.knative.dev/"$SERVICE" \
      -n "$NAMESPACE" --for=condition=Ready --timeout=120s
    kubectl --context "$CONTEXT" get service.serving.knative.dev "$SERVICE" -n "$NAMESPACE"
    ```

    Expected result: `READY` is `True`, a URL is shown, and `LATESTCREATED` matches `LATESTREADY`. A successful resource-creation command alone is not this readiness check. With no custom readiness probe, v1.24 supplies a TCP probe for the primary container, not an application-response test; see [probe defaulting](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/serving/v1/revision_defaults.go#L153-L166){target=_blank} and [configuring probes](configure-probing.md). Complete the request check below even when the Service reports Ready.

    If the wait fails or the Revision is not Ready, inspect conditions before continuing:

    ```bash
    kubectl --context "$CONTEXT" describe service.serving.knative.dev "$SERVICE" -n "$NAMESPACE"
    ```

    Check image access, the listening port, and application startup configuration according to the reported condition. Use [Serving application debugging](../troubleshooting/debugging-application-issues.md) for further checks; do not treat an unready Service as a successful deployment.

2. Obtain the URL from the created Service:

    ```bash
    URL=$(kubectl --context "$CONTEXT" get service.serving.knative.dev "$SERVICE" \
      -n "$NAMESPACE" -o jsonpath='{.status.url}')
    printf '%s\n' "$URL"
    ```

    Confirm the URL is nonempty. Use this URL rather than an example hostname, and continue only after readiness succeeds.

3. Request the endpoint:

    ```bash
    curl --fail --show-error --location --max-time 60 "${URL}${REQUEST_PATH}"
    ```

    For the unchanged hello-world example, expect:

    ```text
    Hello Go Sample v1!
    ```

    For your image, compare the response with the expected result for your chosen endpoint. A Ready Service without a successful request does not verify DNS, ingress reachability, or application behavior. If the request fails, check the URL, DNS/network access, and application requirements; the debugging guide includes ingress-specific checks. Do not disable TLS verification to make a failed request appear successful.

## What was created

Serving manages a Revision, Configuration, and Route for the Service. Its autoscaler adjusts replicas according to traffic and configuration; scale to zero requires an eligible autoscaler, enabled scale-to-zero, and permissive scale bounds. See the [autoscaling overview](../autoscaling/README.md) for behavior, settings, and related tasks.

For an existing Kubernetes Deployment, use the [illustrative Deployment-to-Service mapping](../convert-deployment-to-knative-service.md) to prepare a separate Knative manifest. This guide does not remove that workload or redirect its clients.
