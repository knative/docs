# Changing the default domain

By default, Knative Serving routes use `example.com` as the default domain. The
fully qualified domain name for a route by default is
`{route}.{namespace}.{default-domain}`.

To change the {default-domain} value there are a few steps involved:

!!! tip
    Customizing a domain template affects your cluster globally.
    If you want to customize the domain of each service, use `DomainMapping` instead.
    For more information, see [Configuring custom domains](services/custom-domains.md).

## Edit using kubectl

1. Edit the domain configuration config-map to replace `example.com` with your
   own domain, for example `mydomain.com`:

     ```bash
     kubectl edit configmap config-domain -n knative-serving
     ```

     This command opens your default text editor and allows you to edit the [ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/domain.yaml).

     ```yaml
     apiVersion: v1
     data:
       _example: |
         ################################
         #                              #
         #    EXAMPLE CONFIGURATION     #
         #                              #
         ################################
         # ...
         example.com: |
     kind: ConfigMap
     ```

1. Edit the file to replace `example.com` with the domain you want to use, then remove the `_example` key and save your changes. In this example, `mydomain.com` is configured as the domain for all routes:

     ```yaml
     apiVersion: v1
     data:
       mydomain.com: ""
     kind: ConfigMap
     [...]
     ```

## Apply from a file

You can also apply an updated domain configuration:

1. Create a YAML file using the following template:

     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: config-domain
       namespace: knative-serving
     data:
       # These are example settings of domain.
       # example.org will be used for routes having app=prod.
       example.org: |
         selector:
           app: prod
       # Default value for domain, for routes that does not have app=prod labels.
       # Although it will match all routes, it is the least-specific rule so it
       # will only be used if no other domain matches.
       example.com: ""
     ```
     Replace `example.org` and `example.com` with the new domain you want to use.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

## Deploy an application

> If you have an existing deployment, Knative reconciles the change made to the ConfigMap, and automatically updates the host name for all of the deployed Services and Routes.

Deploy an app (for example,
[`helloworld-go`](samples/hello-world/helloworld-go/README.md)), to your
cluster as normal. You can retrieve the URL in Knative Route "helloworld-go"
with the following command:

```bash
kubectl get route helloworld-go --output jsonpath="{.status.url}"
```

You should see the full customized domain: `helloworld-go.default.mydomain.com`.

## Verify the domain using temporary DNS

If you are using curl to access the sample applications, or your own Knative app, there is a temporary approach
to verify the customized domain.

Instruct `curl` to connect to the External IP or CNAME defined by the
networking layer mentioned in [Install a networking layer](../install/serving/install-serving-with-yaml.md#install-a-networking-layer), and use the `-H "Host:"` command-line
option to specify the Knative application's host name.
For example, if the networking layer defines your External IP and port to be `http://192.168.39.228:32198` and you wish to access the `helloworld-go` application mentioned earlier, use:

```bash
curl -H "Host: helloworld-go.default.mydomain.com" http://192.168.39.228:32198
```

In the case of the provided `helloworld-go` sample application, using the default configuration, the output is:

```
Hello Go Sample v1!
```

Refer to the [Publish your Domain](#publish-your-domain) method for a permanent solution.

## Publish your Domain

Follow these steps to make your domain publicly accessible:

### Update your DNS records

To publish your domain, you need to update your DNS provider to point to the IP
address for your service ingress.

- Create a [wildcard record](https://support.google.com/domains/answer/4633759)
  for the namespace and custom domain to the ingress IP Address, which would
  enable hostnames for multiple services in the same namespace to work without
  creating additional DNS entries.

  ```dns
  *.default.mydomain.com                   59     IN     A   35.237.28.44
  ```

- Create an A record to point from the fully qualified domain name to the IP
  address of your Knative gateway. This step needs to be done for each Knative
  Service or Route created.

  ```dns
  helloworld-go.default.mydomain.com        59     IN     A   35.237.28.44
  ```

If you are using Google Cloud DNS, you can find step-by-step instructions in the
[Cloud DNS quickstart](https://cloud.google.com/dns/quickstart).

Once the domain update has propagated, you can access your app using the fully
qualified domain name of the deployed route, for example
`http://helloworld-go.default.mydomain.com`
