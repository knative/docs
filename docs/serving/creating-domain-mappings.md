---
title: "Creating a Mapping between a Custom Domain Name and a Knative Service (Alpha)"
linkTitle: "Creating Domain Mappings (Alpha)"
weight: 64
type: "docs"
---

Knative Services are automatically given a default domain name based on the
cluster configuration, e.g. "mysvc.mynamespace.mydomain". You can also map a
single custom domain name that you own to a specific Knative Service using the
Domain Mapping feature, if enabled.

For example, if you own the "mydomain.com" domain name, and configure its DNS
to reference your Knative cluster, you can use the DomainMapping feature to
have this domain be served by a Knative Service.

## Before you begin

1. You need to enable the DomainMapping feature (and a supported Knative
   Ingress implementation) to use it. See [the Install instructions](../install/).
1. To map a custom domain to a Knative Service, you should first [create a Knative
Service](https://knative.dev/docs/serving/creating-services/).

## Creating a Domain Mapping

To create a mapping from a custom domain to a Knative Service, you need to
create a YAML file that defines a Domain Mapping.
This YAML file specifies the domain name to map and the Knative Service to use
to service requests.

You will also need to point the domain name at your Knative cluster using the
tools provided by your domain registrar.

Domain Mappings map a single, non-wildcard domain to a specific Knative
Service. For example in the example yaml below, the "mydomain.com" Domain
Mapping maps only "mydomain.com" and not "www.mydomain.com". You can create
multiple Domain Mappings to map multiple domains.

### Procedure

1. Create a new file named `domainmapping.yaml` containing the following information.
  ```yaml
  apiVersion: serving.knative.dev/v1alpha1
  kind: DomainMapping
  metadata:
   name: mydomain.com
   namespace: default
  spec:
   ref:
     name: helloworld-go
     kind: Service
     apiVersion: serving.knative.dev/v1
  ```
  * `name`(metadata): The domain name you wish to map to the Knative Service.
  * `namespace`: The namespace that both the DomainMapping and Knative Service use.
  * `name`(ref): The Knative Service which should be used to service requests
    for the custom domain name.

1. From the directory where the new `domainmapping.yaml` file was created,
   deploy the domain mapping by applying the `domainmapping.yaml` file.
 ```
 kubectl apply --filename domainmapping.yaml
 ```

1. You will also need to point the "mydomain.com" domain name at the IP address
   of your Knative cluster. Details of this step differ depending on your
   domain registrar.
