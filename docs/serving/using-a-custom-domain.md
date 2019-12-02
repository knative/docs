---
title: "Setting up a custom domain"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 55
type: "docs"
---

By default, Knative Serving routes use `example.com` as the default domain. The
fully qualified domain name for a route by default is
`{route}.{namespace}.{default-domain}`.

To change the {default-domain} value there are a few steps involved:

## Edit using kubectl

1. Edit the domain configuration config-map to replace `example.com` with your
   own domain, for example `mydomain.com`:

   ```shell
   kubectl edit cm config-domain --namespace knative-serving
   ```

   This command opens your default text editor and allows you to edit the [config
   map](https://github.com/knative/serving/blob/master/config/config-domain.yaml).

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

1. Edit the file to replace `example.com` with the domain you'd like to use,
   remove the `_example` key and save your changes.
   In this example, we configure `mydomain.com` for all routes:

   ```yaml
   apiVersion: v1
   data:
     mydomain.com: ""
   kind: ConfigMap
   [...]
   ```

## Apply from a file

You can also apply an updated domain configuration:

1. Create a new file, `config-domain.yaml` and paste the following text,
   replacing the `example.org` and `example.com` values with the new domain you
   want to use:

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

1. Apply updated domain configuration to your cluster:

   ```shell
   kubectl apply --filename config-domain.yaml
   ```

## Deploy an application

> If you have an existing deployment, Knative will reconcile the change made to
> the configuration map and automatically update the host name for all of the
> deployed services and routes.

Deploy an app (for example,
[`helloworld-go`](./samples/hello-world/helloworld-go/README.md)), to your
cluster as normal. You can retrieve the URL in Knative Route "helloworld-go"
with the following command:

```shell
kubectl get route helloworld-go --output jsonpath="{.status.url}"
```

You should see the full customized domain: `helloworld-go.default.mydomain.com`.

And you can check the IP address of your Knative gateway by running:

```shell
export INGRESSGATEWAY=istio-ingressgateway

if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    export INGRESSGATEWAY=istio-ingressgateway
fi

kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"
```

## Local DNS setup

You can map the domain to the IP address of your Knative gateway in your local
machine with:

```shell
INGRESSGATEWAY=istio-ingressgateway

export GATEWAY_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`

# helloworld-go is the generated Knative Route of "helloworld-go" sample.
# You need to replace it with your own Route in your project.
export DOMAIN_NAME=`kubectl get route helloworld-go --output jsonpath="{.status.url}" | cut -d'/' -f 3`

# Add the record of Gateway IP and domain name into file "/etc/hosts"
echo -e "$GATEWAY_IP\t$DOMAIN_NAME" | sudo tee -a /etc/hosts

```

You can now access your domain from the browser in your machine and do some
quick checks.

## Publish your Domain

Follow these steps to make your domain publicly accessible:

### Set static IP for Knative Gateway

You might want to
[set a static IP for your Knative gateway](./gke-assigning-static-ip-address.md),
so that the gateway IP does not change each time your cluster is restarted.

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
