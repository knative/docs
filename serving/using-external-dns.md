# Use ExternalDNS to automate DNS setup

[ExternalDNS](https://github.com/kubernetes-incubator/external-dns) is a tool 
that synchronizes exposed Kubernetes Services and Ingresses with DNS providers.

This doc introduces how to set up ExternalDNS within Knative cluster to 
automate the process of publishing the domain used in Knative.

## Prerequisite

1. A Kubernetes cluster with [Knative Serving](https://github.com/knative/docs/blob/master/install/README.md) installed.
1. Own the domain that will be used in Knative.
1. Follow the steps [Edit using kubectl](https://github.com/knative/docs/blob/master/serving/using-a-custom-domain.md#edit-using-kubectl) to make Knative 
use your owned domain.

## Setup steps

In this document, we use the GCP as an example to show how to set up 
ExternalDNS. You can find detailed instructions for other cloud providers in [ExternalDNS documentation](https://github.com/kubernetes-incubator/external-dns#deploying-to-a-cluster).

### Choose a DNS provider

Skip this step if you already have a DNS provider for your owned domain.

Here is a [list](https://github.com/kubernetes-incubator/external-dns#the-latest-release-v05) of DNS providers supported by ExternalDNS.
Choose a DNS provider from the list.

### Create a DNS zone for managing DNS records

Skip this step if you already have a zone for managing DNS records of your 
custom domain.

A DNS zone which will contain the managed DNS records needs to be created.
Assume your custom domain is `external-dns-test.my-org.do`.

#### Google Cloud Platform
You can use the following command to create a DNS zone if you are using Google Cloud DNS.
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
You should see the result like:
```
NAME                             TYPE  TTL    DATA
external-dns-test.my-org.do.  NS    21600  ns-cloud-e1.googledomains.com.,ns-cloud-e2.googledomains.com.,ns-cloud-e3.googledomains.com.,ns-cloud-e4.googledomains.com.
```
In this case the DNS nameservers are `ns-cloud-{e1-e4}.googledomains.com`. But 
yours could slightly differ, e.g. {a1-a4}, {b1-b4} etc.

If this zone has the parent zone, you need to add NS records of this zone into 
the parent zone so that this zone can be found from the parent.
Assuming the parent zone is `my-org-do` and the parent domain is `my-org.do`, 
and the parent zone is also hosted at Google Cloud DNS, you can follow below 
steps to add the NS records of this zone into the parent zone. 
```shell
gcloud dns record-sets transaction start --zone "my-org-do"
gcloud dns record-sets transaction add ns-cloud-e{1..4}.googledomains.com. \
    --name "external-dns-test.my-org.do." --ttl 300 --type NS --zone "my-org-do"
gcloud dns record-sets transaction execute --zone "my-org-do"
```

### Deploy ExternalDNS

#### Google Cloud Platform
Apply the [manifest](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/gke.md#manifest-for-clusters-without-rbac-enabled) to 
install ExternalDNS. Note that you need to set the argument `domain-filter` to 
your custom domain.

You should see ExternalDNS is installed by running
```shell
kubectl get deployment external-dns
```

### Configuration Knative Gateway service

In order to publish the Knative Gateway service, the annotation `external-dns.alpha.kubernetes.io/hostname: '*.external-dns-test.my-org.do'`
needs to be added into Knative gateway service.
```shell
kubectl edit svc knative-ingressgateway -n istio-system
```
This command opens your default text editor and allows you to edit the 
`knative-ingressgateway` service.

### Verify ExternalDNS works

After roughly two minutes check that a corresponding DNS record for your 
service was created.

#### Google Cloud Platform

```shell
gcloud dns record-sets list     --zone "external-dns-zone"     --name "*.external-dns-test.my-org.do."
```
You should see the result like
```
NAME                            TYPE  TTL  DATA
*.external-dns-test.my-org.do.  A     300  35.231.248.30
*.external-dns-test.my-org.do.  TXT   300  "heritage=external-dns,external-dns/owner=my-identifier,external-dns/resource=service/istio-system/knative-ingressgateway"
```

### Verify domain has been published

You can check if the domain has been published to the Internet with
```shell
host test.external-dns-test.my-org.do
```
You should see the below result after the domain is published
```
test.external-dns-test.my-org.do has address 35.231.248.30
```
> Note: The process of publishing the domain to the Internet can take several 
minutes.
