# Configuring outbound network access

This guides walks you through enabling outbound network access for a Knative app.

Knative blocks all outbound traffic by default. To enable outbound access (when you want to connect 
to the Cloud Storage API, for example), you need to change the scope of the proxy IP range by editing
the `config-network` map.

## Determining the IP scope of your cluster

To set the correct scope, you need to determine the IP ranges of your cluster. The scope varies 
depending on your platform:

* For Google Container Engine (GKE) run the following command to determine the scope (insert the 
  appropriate value for `your-cluster-id` and change the `--zone` parameter as necessary): 
  ```shell
  gcloud container clusters describe your-cluster-id --zone=us-west1-c | grep -e clusterIpv4Cidr -e servicesIpv4Cidr
  ```
* For IBM Cloud Private run the following command: 
  ```shell
  cat cluster/config.yaml | grep service_cluster_ip_range
  ```
* For IBM Cloud Kubernetes Service use `172.30.0.0/16,172.20.0.0/16,10.10.10.0/24`
* For Azure Container Service (ACS) use `10.244.0.0/16,10.240.0.0/16`
* For Minikube use `10.0.0.1/24`

## Setting the IP scope  

The `istio.sidecar.includeOutboundIPRanges` parameter in the `config-network` map specifies 
the IP ranges that Istio sidecar intercepts. To allow outbound access, replace the default parameter  
value with the IP ranges of your cluster.

Run the following command to edit the `config-network` map:

```shell
kubectl edit configmap config-network -n knative-serving
```

Then, use an editor of your choice to change the `istio.sidecar.includeOutboundIPRanges` parameter value
from `*` to the IP range you need. Separate multiple IP entries with a comma. For example: 

```
data:
  istio.sidecar.includeOutboundIPRanges: '10.16.0.0/14,10.19.240.0/20'
```

By default, the `istio.sidecar.includeOutboundIPRanges` parameter is set to `*`, 
which means that Istio intercepts all traffic within the cluster as well as all traffic that is going 
outside the cluster. Istio blocks all traffic that is going outside the cluster unless
you create the necessary egress rules.

When you set the parameter to a valid set of IP address ranges, Istio will no longer intercept 
traffic that is going to the IP addresses outside the provided ranges, and you don't need to specify
any egress rules.

If you omit the parameter or set it to `''`, Knative uses the value of the `global.proxy.includeIPRanges` 
parameter that is provided at Istio deployment time. In the default Knative Serving
deployment, `global.proxy.includeIPRanges` value is set to `*`.

If an invalid value is passed, `''` is used instead.
