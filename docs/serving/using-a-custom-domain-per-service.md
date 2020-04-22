
---
title: "Setting up a custom domain per Service"
weight: 55
type: "docs"
---

By default, Knative uses the `{route}.{namespace}.{default-domain}` fully qualified domain name for the Service, where `default-domain` is `example.com`. You are able to change the `default-domain` following the [Setting up a custom domain](./using-a-custom-domain.md) guide.

This guide documents the process to use a custom FQDN for a Service, like `my-service.example.com`, created by [@bsideup](https://bsideup.github.io/posts/knative_custom_domains/).

> There is currently no official process to set up a custom domain per Service. The topic is being discussed [here](https://github.com/knative/serving/issues/2985).

## Edit using kubectl

1. Edit the `domainTemplate` entry on the `config-network` configuration. You can find more information about it [here](https://github.com/knative/serving/blob/master/config/core/configmaps/network.yaml#L89):

   ```shell
   kubectl edit cm config-network --namespace knative-serving
   ```

   Replace the `domainTemplate` with the following (the spaces must be respected):

   ```yaml
   [...]
   data:
     [...]
     domainTemplate: |-
       {{if index .Annotations "custom-hostname" -}}
         {{- index .Annotations "custom-hostname" -}}
       {{else -}}
         {{- .Name}}.{{.Namespace -}}
       {{end -}}
       .{{.Domain}}
   ```

   Save and close your editor.

## Edit the Service

1. In a Service definition, add the `custom-hostname` annotation:

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: hello-world
     annotations:
       # the Service FQDN will become hello-world.{default-domain}
       custom-hostname: hello-world
   spec:
   [...]
   ```

   Apply your changes.

## Verify the changes

1. Verify that the Service was created with the specified hostname:

  ```shell
  kubectl get ksvc hello-world

  NAME          URL                              LATESTCREATED       LATESTREADY         READY   REASON
  hello-world   http://hello-world.example.com   hello-world-nfqh2   hello-world-nfqh2   True
  ```
