## Installation
> The startup script running on the right will install the `kn` cli and wait for kubernetes to start. Once you see a prompt, you can click on the commands below at your own pace, and they will be copied and run for you in the terminal on the right.

1. Install Knative Serving's core components
    ```
    kubectl apply --filename https://github.com/knative/serving/releases/download/${latest_version}/serving-crds.yaml
    kubectl apply --filename https://github.com/knative/serving/releases/download/${latest_version}/serving-core.yaml
    ```{{execute}}
1. Install contour as the networking layer. (Knative also supports Courier, Gloo, Istio and Kourier as options)
    ```
    kubectl apply --filename https://github.com/knative/net-contour/releases/download/${latest_version}/contour.yaml
    kubectl apply --filename https://github.com/knative/net-contour/releases/download/${latest_version}/net-contour.yaml
    ```{{execute}}
1. Configure Knative Serving to use Contour by default
    ```
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
    ```{{execute}}
