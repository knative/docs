# Using ExternalDNS to automate DNS setup

[ExternalDNS](https://github.com/kubernetes-incubator/external-dns) is a tool 
that synchronizes exposed Kubernetes Services and Ingresses with DNS providers.

This doc explains how to set up ExternalDNS within a Knative cluster to 
automate the process of publishing the domain used in Knative.

## Prerequisite

1. A Kubernetes cluster with [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md) installed.
1. A public domain that will be used in Knative.
1. Configure Knative to use your custom domain.
```shell
kubectl edit cm config-domain -n knative-serving
```
This command opens your default text editor and allows you to edit the config 
map.
```
apiVersion: v1
data:
  example.com: ""
kind: ConfigMap
[...]
```
Edit the file to replace `example.com` with the domain you'd like to use and 
save your changes. In this example, we use domain `external-dns-test.my-org.do`
 for all routes:
```
apiVersion: v1
data:
  external-dns-test.my-org.do: ""
kind: ConfigMap
[...]
```

## Setup steps

This guide uses Google Cloud Platform as an example to show how to set up 
ExternalDNS. You can find detailed instructions for other cloud providers in the
[ExternalDNS documentation](https://github.com/kubernetes-incubator/external-dns#deploying-to-a-cluster).

### Choose a DNS provider

Skip this step if you already have a DNS provider for your domain.

Here is a [list](https://github.com/kubernetes-incubator/external-dns#the-latest-release-v05)
of DNS providers supported by ExternalDNS. Choose a DNS provider from the list.

### Create a DNS zone for managing DNS records

Skip this step if you already have a zone for managing the DNS records of your 
custom domain.

A DNS zone which will contain the managed DNS records needs to be created.
Assume your custom domain is `external-dns-test.my-org.do`.

Use the following command to create a DNS zone with [Google Cloud DNS](https://cloud.google.com/dns/):
```shell
gcloud dns managed-zones create "external-dns-zone" \
    --dns-name "external-dns-test.my-org.do." \
    --description "Automatically managed zone by kubernetes.io/external-dns"
```
Make a note of the nameservers that were assigned to your new zone.
```shell
gcloud dns record-sets list \
    --zone "external-dns-zone" \
    --name "external-dns-test.my-org.do." \
    --type NS
```
You should see output similar to the following:
```
NAME                             TYPE  TTL    DATA
external-dns-test.my-org.do.  NS    21600  ns-cloud-e1.googledomains.com.,ns-cloud-e2.googledomains.com.,ns-cloud-e3.googledomains.com.,ns-cloud-e4.googledomains.com.
```
In this case, the DNS nameservers are `ns-cloud-{e1-e4}.googledomains.com`. 
Yours could differ slightly, e.g. {a1-a4}, {b1-b4} etc.

If this zone has the parent zone, you need to add NS records of this zone into 
the parent zone so that this zone can be found from the parent.
Assuming the parent zone is `my-org-do` and the parent domain is `my-org.do`, 
and the parent zone is also hosted at Google Cloud DNS, you can follow these 
steps to add the NS records of this zone into the parent zone: 
```shell
gcloud dns record-sets transaction start --zone "my-org-do"
gcloud dns record-sets transaction add ns-cloud-e{1..4}.googledomains.com. \
    --name "external-dns-test.my-org.do." --ttl 300 --type NS --zone "my-org-do"
gcloud dns record-sets transaction execute --zone "my-org-do"
```

### Deploy ExternalDNS

#### Google Cloud DNS

Use the following command to apply the [manifest](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/gke.md#manifest-for-clusters-without-rbac-enabled) to install ExternalDNS 
```shell
cat <<EOF | kubectl apply -f -
<the-content-of-manifest-with-custom-domain-filter>
EOF
```
Note that you need to set the argument `domain-filter` to your custom domain.

You should see ExternalDNS is installed by running:
```shell
kubectl get deployment external-dns
```

### Configuring Knative Gateway service

In order to publish the Knative Gateway service, the annotation
`external-dns.alpha.kubernetes.io/hostname: '*.external-dns-test.my-org.do'`
needs to be added into Knative gateway service:
```shell
kubectl edit svc knative-ingressgateway -n istio-system
```
This command opens your default text editor and allows you to add the 
annotation to `knative-ingressgateway` service. Below is an example to show 
where to add the annotation
```
apiVersion: v1
kind: Service
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: '*.external-dns-test.my-org.do'
    ...
```

### Verify ExternalDNS works

After roughly two minutes, check that a corresponding DNS record for your 
service was created.

```shell
gcloud dns record-sets list     --zone "external-dns-zone"     --name "*.external-dns-test.my-org.do."
```
You should see output similar to:

```
NAME                            TYPE  TTL  DATA
*.external-dns-test.my-org.do.  A     300  35.231.248.30
*.external-dns-test.my-org.do.  TXT   300  "heritage=external-dns,external-dns/owner=my-identifier,external-dns/resource=service/istio-system/knative-ingressgateway"
```

### Verify domain has been published

You can check if the domain has been published to the Internet be entering
the following command:
```shell
host test.external-dns-test.my-org.do
```
You should see the below result after the domain is published:
```
test.external-dns-test.my-org.do has address 35.231.248.30
```
> Note: The process of publishing the domain to the Internet can take several 
minutes.
