# Assigning a static IP address for Knative on Kubernetes Engine

If you are running Knative on Google Kubernetes Engine and want to use a 
[custom domain](./using-a-custom-domain.md) with your apps, you need to configure a 
static IP address to ensure that your custom domain mapping doesn't break.

Knative uses the shared `knative-shared-gateway` Gateway under the
`knative-serving` namespace, to serve all incoming traffic within the
Knative service mesh. The IP address to access the gateway is the 
external IP address of the "knative-ingressgateway" service under the 
`istio-system` namespace. Therefore, in order to set a static IP for the 
Knative shared gateway `knative-shared-gateway`, you must to set the 
external IP address of the `knative-ingressgateway` service to a static IP.

## Step 1: Reserve a static IP address

Reserve a regional static IP address using the Google Cloud Platform console:

1. Follow the [Kubernetes Engine instructions](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#reserve_new_static) to reserve a new static IP address.
1. In the Cloud Platform console:
   1. Select the **Regional** Type.
   1. In the **Region** menu, specify the region where your Knative cluster is running. 
   
      For example, select the `us-west1` region if your deployed your cluster to the `us-west1-c` zone.
      
1. Copy the **External Address** of the static IP you created.

## Step 2: Update the external IP of the `knative-ingressgateway` service

Run following command to configure the external IP of the 
`knative-ingressgateway` service to the static IP that you reserved:
```shell
kubectl patch svc knative-ingressgateway -n istio-system --patch '{"spec": { "loadBalancerIP": "<your-reserved-static-ip>" }}'
```

## Step 3: Verify the static IP address of `knative-ingressgateway` service

Run the following command to ensure that the external IP of the "knative-ingressgateway" service has been updated:
```shell
kubectl get svc knative-ingressgateway -n istio-system
```
The result should be something like the following:
```
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                      AGE
knative-ingressgateway   LoadBalancer   12.34.567.890   98.765.43.210   80:32380/TCP,443:32390/TCP,32400:32400/TCP   5m
```
Note: The process of updating an external IP address can take several minutes.
