---
title: "Setting up a custom domain per Service"
linkTitle: "Setting up a custom domain per Service"
weight: 64
type: "docs"
aliases:
  - /docs/serving/using-a-custom-domain-per-service
  - /docs/serving/services/using-a-custom-domain-per-service
---

# Setting up a custom domain per Service

Knative services are automatically given a default domain name based on the
cluster configuration, e.g. "mysvc.mynamespace.mydomain". You can also map a
single custom domain name that you own to a specific Knative service using the
domain mapping feature, if enabled.

For example, if you own the `example.org` domain name, and configure its DNS
to reference your Knative cluster, you can use domain mapping to
have this domain be served by a Knative service.

## Before you begin

1. You need to enable the domain mapping feature, as well as a supported Knative
   Ingress implementation to use it. See [Install optional Serving extensions](../install/install-extensions.md#install-optional-serving-extensions).
1. [Create a Knative service](../serving/services/creating-services) that you can map a domain to.
1. You will need a domain name to map, and the ability to change its DNS to
   point to your Knative Cluster. The details of this step are dependant on
   your domain registrar.

## Creating a Domain Mapping

To create a mapping from a custom domain name that you control to a Knative
Service, you need to create a YAML file that defines a Domain Mapping. This
YAML file specifies the domain name to map and the Knative Service to use to
service requests.

You will also need to point the domain name at your Knative cluster using the
tools provided by your domain registrar.

Domain Mappings map a single, non-wildcard domain to a specific Knative
Service. For example in the example yaml below, the "example.org" Domain
Mapping maps only "example.org" and not "www.example.org". You can create
multiple Domain Mappings to map multiple domains and subdomains.

### Procedure

1. Create a new file named `domainmapping.yaml` containing the following information.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: DomainMapping
   metadata:
     name: example.org
     namespace: default
   spec:
     ref:
       name: helloworld-go
       kind: Service
       apiVersion: serving.knative.dev/v1
   ```

   - `name`(metadata): The domain name you wish to map to the Knative service.
   - `namespace`: The namespace that both domain mapping and the Knative service use.
   - `name`(ref): The Knative service which should be used to service requests
     for the custom domain name. You can also map to other targets as long as
     they conform to the Addressable contract and their resolved URL is of the form `{name}.{namespace}.{clusterdomain}` where `{name}` and `{namespace}`are the name and namespace of a Kubernetes service, and `{clusterdomain}`is the cluster domain. Objects conforming to this contract include Knative services and Routes, and Kubernetes services.

1. From the directory where the new `domainmapping.yaml` file was created,
   deploy the domain mapping by applying the `domainmapping.yaml` file.

   ```
   kubectl apply -f domainmapping.yaml
   ```

1. You will also need to point the `example.org` domain name at the IP
   address of your Knative cluster. Details of this step differ depending on
   your domain registrar.
