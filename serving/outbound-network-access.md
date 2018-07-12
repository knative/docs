# How to configure outbound network access

WIP:
Specifies the IP ranges that Istio sidecar will intercept.
Replace this with the IP ranges of your cluster (see below for some examples).
Separate multiple entries with a comma.
Example: "10.4.0.0/14,10.7.240.0/20"

If set to "*" Istio will intercept all traffic within
the cluster as well as traffic that is going outside the cluster.
Traffic going outside the cluster will be blocked unless
necessary egress rules are created. 

If omitted or set to "", value of global.proxy.includeIPRanges
provided at Istio deployment time is used. In default Knative serving
deployment, global.proxy.includeIPRanges value is set to "*".

If an invalid value is passed, "" is used instead.
 
If valid set of IP address ranges are put into this value,
Istio will no longer intercept traffic going to IP addresses
outside the provided ranges and there is no need to specify
egress rules.

## Getting IP scope

To determine the IP ranges of your cluster:

* Google Container Engine (GKE): gcloud container clusters describe XXXXXXX --zone=XXXXXX | grep -e clusterIpv4Cidr -e servicesIpv4Cidr
* IBM Cloud Private: cat cluster/config.yaml | grep service_cluster_ip_range
* IBM Cloud Kubernetes Service: "172.30.0.0/16,172.20.0.0/16,10.10.10.0/24"
* Azure Container Service(ACS): "10.244.0.0/16,10.240.0.0/16"
* Minikube: "10.0.0.1/24"
 
## Apply IP Scope to your cluster 

```shell
kubectl edit configmap config-network -n knative-serving
```

Changed `istio.sidecar.includeOutboundIPRanges` from `*` to the IP range (e.g. 10.16.0.0/14,10.19.240.0/20)

