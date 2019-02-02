---
title: "Assigning a static IP address for Knative on Kubernetes Engine"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 35
---

If you are running Knative on Google Kubernetes Engine and want to use a
[custom domain](../using-a-custom-domain/) with your apps, you need to
configure a static IP address to ensure that your custom domain mapping doesn't
break.

Knative configures an Istio Gateway CRD named `knative-ingress-gateway` under
the `knative-serving` namespace to serve all incoming traffic within the Knative
service mesh. The IP address to access the gateway is the external IP address of
the "istio-ingressgateway" service under the `istio-system` namespace.
Therefore, in order to set a static IP for the gateway you must to set the
external IP address of the `istio-ingressgateway` service to a static IP.

## Step 1: Reserve a static IP address

You can reserve a regional static IP address using the Google Cloud SDK or the
Google Cloud Platform console.

Using the Google Cloud SDK:

1.  Enter the following command, replacing IP_NAME and REGION with appropriate
    values. For example, select the `us-west1` region if you deployed your
    cluster to the `us-west1-c` zone:
    ```shell
    gcloud beta compute addresses create IP_NAME --region=REGION
    ```
    For example:
    ```shell
    gcloud beta compute addresses create knative-ip --region=us-west1
    ```
1.  Enter the following command to get the newly created static IP address:
    ```shell
    gcloud beta compute addresses list
    ```

In the
[GCP console](https://console.cloud.google.com/networking/addresses/add?_ga=2.97521754.-475089713.1523374982):

1.  Enter a name for your static address.
1.  For **IP version**, choose IPv4.
1.  For **Type**, choose **Regional**.
1.  From the **Region** drop-down, choose the region where your Knative cluster
    is running.

    For example, select the `us-west1` region if you deployed your cluster to
    the `us-west1-c` zone.

1.  Leave the **Attached To** field set to `None` since we'll attach the IP
    address through a config-map later.
1.  Copy the **External Address** of the static IP you created.

## Step 2: Update the external IP of `istio-ingressgateway` service

Run following command to configure the external IP of the
`istio-ingressgateway` service to the static IP that you reserved:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

kubectl patch svc $INGRESSGATEWAY --namespace istio-system --patch '{"spec": { "loadBalancerIP": "<your-reserved-static-ip>" }}'
```

## Step 3: Verify the static IP address of `istio-ingressgateway` service

Run the following command to ensure that the external IP of the ingressgateway service has been updated:

```shell
kubectl get svc $INGRESSGATEWAY --namespace istio-system
```

The output should show the assigned static IP address under the EXTERNAL-IP
column:

```
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                                      AGE
xxxxxxx-ingressgateway   LoadBalancer   12.34.567.890   98.765.43.210   80:32380/TCP,443:32390/TCP,32400:32400/TCP   5m
```

> Note: Updating the external IP address can take several minutes.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
