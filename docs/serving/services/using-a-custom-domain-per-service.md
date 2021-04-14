---
title: "Setting up a custom domain per Service"
weight: 04
type: "docs"
aliases:
  - /docs/serving/using-a-custom-domain-per-service
---

By default, Knative uses the `{route}.{namespace}.{default-domain}` fully qualified domain name for services, where `default-domain` is `example.com`.

You can change the `default-domain` by [Setting up a custom domain](../using-a-custom-domain). You can also set a custom domain per service, by using a custom FQDN for a service, or by using [custom domain mapping](../creating-domain-mappings/).

## Procedure

1. Edit the `domainTemplate` entry on the `config-network` configuration:

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

1. In a service definition, add the `custom-hostname` annotation:

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

1. Verify that the service was created with the specified hostname:

    ```shell
    kubectl get ksvc hello-world

    NAME          URL                              LATESTCREATED       LATESTREADY         READY   REASON
    hello-world   http://hello-world.example.com   hello-world-nfqh2   hello-world-nfqh2   True
    ```
