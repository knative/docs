# Assigning a static IP address for Knative on Kubernetes Engine

If you are running Knative on Google Kubernetes Engine and want to use a 
[custom domain](./using-a-custom-domain.md) with your apps, you need to configure a 
static IP address to ensure that your custom domain mapping doesn't break.

Knative uses the shared `knative-shared-gateway` Gateway under the
`knative-serving` namespace to serve all incoming traffic within the
Knative service mesh. The IP address to access the gateway is the 
external IP address of the "knative-ingressgateway" service under the 
`istio-system` namespace. Therefore, in order to set a static IP for the 
Knative shared gateway `knative-shared-gateway`, you must to set the 
external IP address of the `knative-ingressgateway` service to a static IP.

## Step 1: Reserve a static IP address

You can reserve a regional static IP address using the Google Cloud SDK or the
Google Cloud Platform console.

Using the Google Cloud SDK:
   1. Enter the following command, replacing IP_NAME and REGION with appropriate
      values. For example, select the `us-west1` region if you deployed your
      cluster to the `us-west1-c` zone.
   	  ```shell
      gcloud beta compute addresses create IP_NAME --region=REGION
   	  ```
   	  For example:
   	  ```shell
      gcloud beta compute addresses create knative-ip --region=us-west1
   	  ```
   1. Enter the following command to get the newly created static IP address:
   	  ```shell
   	  gcloud beta compute addresses list
   	  ```

In the [GCP console](https://console.cloud.google.com/networking/addresses/add?_ga=2.97521754.-475089713.1523374982):
   1. Enter a name for your static address.
   1. For **IP version**, choose IPv4.
   1. For **Type**, choose **Regional**.
   1. From the **Region** drop-down, choose the region where your Knative cluster is running. 
   
      For example, select the `us-west1` region if you deployed your cluster to the `us-west1-c` zone.
   1. Copy the **External Address** of the static IP you created.


## Step 2: Update the external IP of the `knative-ingressgateway` service

Run following command to configure the external IP of the 
`knative-ingressgateway` service to the static IP that you reserved:
```shell
kubectl patch svc knative-ingressgateway -n istio-system --patch '{"spec": { "loadBalancerIP": "<your-reserved-static-ip>" }}'
service "knative-ingressgateway" patched
```

## Step 3: Verify the static IP address of `knative-ingressgateway` service

Run the following command to ensure that the external IP of the "knative-ingressgateway" service has been updated:
```shell
kubectl get svc knative-ingressgateway -n istio-system
```
The output should show the assigned static IP address under the EXTERNAL-IP column:
```
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                      AGE
knative-ingressgateway   LoadBalancer   12.34.567.890   98.765.43.210   80:32380/TCP,443:32390/TCP,32400:32400/TCP   5m
```
> Note: Updating the external IP address can take several minutes.
