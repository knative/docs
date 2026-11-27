---
audience: developer
components:
  - serving
function: how-to
---

# Creating a Service

You can create a Knative service by applying a YAML file or using the `kn service create` CLI command.

## Prerequisites

To create a Knative service, you will need:

* A Kubernetes cluster with Knative Serving installed. For more information, see [Installing Knative Serving](../../install/yaml-install/serving/install-serving-with-yaml.md).
* Optional: To use the `kn service create` command, you must [install the `kn` CLI](../../client/install-kn.md).

Select the intended cluster and namespace before starting. Both creation
alternatives and the checks below use your currently selected namespace; the
YAML deliberately omits a hard-coded namespace. If you use an explicit namespace
flag instead, use the same namespace for creation and every verification command.

## Procedure

!!! tip

    The following commands create a `helloworld-go` sample service. You can modify these commands, including the container image URL, to deploy your own application as a Knative service.

Create a sample service:

=== "Apply YAML"

    1. Create a YAML file using the following example:

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
                  env:
                    - name: TARGET
                      value: "Go Sample v1"
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

=== "kn CLI"

    ```bash
    kn service create helloworld-go --image ghcr.io/knative/helloworld-go:latest
    ```

After the service has been created, Knative performs the following tasks:

* Creates a new immutable revision for this version of the app.
* Performs network programming to create a route, ingress, service, and load balancer for your app.
* Automatically scales your pods up and down based on traffic, including to zero active pods.

## Verify readiness and access

Wait for the Service to be ready, replacing `helloworld-go` if you used another name:

```bash
kubectl wait kservice/helloworld-go --for=condition=Ready --timeout=120s
```

Read its URL and send a request:

```bash
SERVICE_URL=$(kubectl get kservice helloworld-go -o jsonpath='{.status.url}')
curl "$SERVICE_URL"
```

For your own image, check that the response matches your application's behavior.
A ready resource means Knative configured the Service; the request also checks
that you can reach it from your environment. If either step fails, inspect
`kubectl describe kservice helloworld-go` and use the
[Serving troubleshooting guide](../troubleshooting/debugging-application-issues.md).
