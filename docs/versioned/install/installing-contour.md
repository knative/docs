---
audience: administrator
components:
  - serving
function: how-to
---

# Installing Contour for Knative

This guide shows how to install Contour in three ways:

- By using Contour’s example YAML.
- By using the Helm chart for Contour.
- By using the Contour gateway provisioner.

It then shows how to deploy a sample workload and route traffic to it through Contour.

This guide uses all default settings. No additional configuration is required.

## Before you begin

This installation requires the following prerequisites:

- A Kubernetes cluster with Knative Serving component installed.
- Knative [load balancing](../serving/load-balancing/README.md) is activated.

## Supported Contour versions

For information about Contour versions, see the Contour [Compatibility Matrix](https://projectcontour.io/resources/compatibility-matrix/).

## Option 1 - YAML installation

1. Use the following command to install Contour:

    ```bash
    kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
    ```

1. Verify the Contour pods are ready:

    ```bash
    kubectl get pods -n projectcontour -o wide
    ```

You should see the following:

- Two Contour pods each with status Running and 1/1 Ready.
- One or more Envoy pods, each with the status Running and 2/2 Ready.

## Option 2 - Helm installation

This option requires Helm to be installed locally.

1. Use the following command to add the `bitnami` chart repository that contains the Contour chart:

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```

1. Install the Contour chart:

    ```bash
    helm install my-release bitnami/contour --namespace projectcontour --create-namespace
    ```

1. Verify Contour is ready:

    ```bash
    kubectl -n projectcontour get po,svc
    ```

You should see the following:

- One instance of pod/my-release-contour-contour with status Running and 1/1 Ready.
- One or more instances of pod/my-release-contour-envoy with each status Running and 2/2 Ready.
- One instance of service/my-release-contour.
- One instance of service/my-release-contour-envoy.

## Option 3: Contour Gateway Provisioner

The Gateway provisioner watches for the creation of Gateway API Gateway resources, and dynamically provisions Contour+Envoy instances based on the Gateway's spec. Note that although the provisioning request itself is made via a Gateway API resource (Gateway), this method of installation still allows you to use any of the supported APIs for defining virtual hosts and routes: Ingress, HTTPProxy, or Gateway API’s HTTPRoute and TLSRoute. In fact, this guide will use an Ingress resource to define routing rules, even when using the Gateway provisioner for installation.

1. Use the following commmand to deploy the Gateway provisioner:

    ```bash
    kubectl apply -f https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
    ```

1. Verify the Gateway provisioner deployment is available:

    ```bash
    kubectl -n projectcontour get deployments
    NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
    contour-gateway-provisioner   1/1     1            1           1m
    ```

1. Create a GatewayClass:

    ```bash
    kubectl apply -f - <<EOF
    kind: GatewayClass
    apiVersion: gateway.networking.k8s.io/v1
    metadata:
      name: contour
    spec:
      controllerName: projectcontour.io/gateway-controller
    EOF
    ```

1. Create a Gateway:

    ```bash
    kubectl apply -f - <<EOF
    kind: Gateway
    apiVersion: gateway.networking.k8s.io/v1
    metadata:
      name: contour
      namespace: projectcontour
    spec:
      gatewayClassName: contour
      listeners:
        - name: http
          protocol: HTTP
          port: 80
          allowedRoutes:
            namespaces:
              from: All
    EOF
    ```

1. Verify the Gateway is available. It may take up to a minute to become available.

    ```bash
    ubectl -n projectcontour get gateways
    NAME        CLASS     ADDRESS         READY   AGE
    contour     contour                   True    27s
    ```

1. Verify the Contour pods are ready by running the following:

    ```bash
    kubectl -n projectcontour get pods
    ```

You should see the following:

- Two Contour pods each with status Running and 1/1 Ready.
- One or move Envoy pods, each with the status Running and 2/2 Ready.

## Test with a web application

Install a web application workload and get some traffic flowing to the backend.

1. Use the following command to install httpbin:

    ```bash
    kubectl apply -f https://projectcontour.io/examples/httpbin.yaml
    ```

1. Verify the pods and service are ready by running:

    ```bash
    kubectl get po,svc,ing -l app=httpbin
    ```

    You should see the following:

    - Three instances of pods/httpbin, each with status Running and 1/1 Ready.
    - One service/httpbin CLUSTER-IP listed on port 80.
    - One Ingress on port 80
  
1. The Helm install configures Contour to filter Ingress and HTTPProxy objects based on the contour IngressClass name. If using Helm, ensure the Ingress has an ingress class of contour with the following command:

    ```bash
    kubectl patch ingress httpbin -p '{"spec":{"ingressClassName": "contour"}}'
    ```

    Now we’re ready to send some traffic to our sample application, via Contour & Envoy.

    For simplicity and compatibility across all platforms we’ll use kubectl port-forward to get traffic to Envoy, but in a production environment you would typically use the Envoy service’s address.

1. Port-forward from your local machine to the Envoy service:

    If using YAML:

    ```bash
    kubectl -n projectcontour port-forward service/envoy 8888:80
    ```

    If using Helm:

    ```bash
    kubectl -n projectcontour port-forward service/my-release-contour-envoy 8888:80
    ```

    If using the Gateway provisioner:

    ```bash
    kubectl -n projectcontour port-forward service/envoy-contour 8888:80
    ```

In a browser or via curl, make a request to `http://local.projectcontour.io:8888`. The `local.projectcontour.io` URL is a public DNS record resolving to `127.0.0.1` to make use of the forwarded port. You should see the httpbin home page.

Congratulations, you have installed Contour, deployed a backend application, created an Ingress to route traffic to the application, and successfully accessed the app with Contour.

## See also

Contour [Getting Started](https://projectcontour.io/getting-started/) documentation.
