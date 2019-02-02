---
title: "Setting up a custom domain"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 55
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

   This command opens your default text editor and allows you to edit the config
   map.

   ```yaml
   apiVersion: v1
   data:
     example.com: ""
   kind: ConfigMap
   [...]
   ```

1. Edit the file to replace `example.com` with the domain you'd like to use and
   save your changes. In this example, we configure `mydomain.com` for all
   routes:

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
[`helloworld-go`](../samples/helloworld-go/)), to your cluster as
normal. You can check the customized domain in Knative Route "helloworld-go"
with the following command:

```shell
kubectl get route helloworld-go --output jsonpath="{.status.domain}"
```

You should see the full customized domain: `helloworld-go.default.mydomain.com`.

And you can check the IP address of your Knative gateway by running:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
export INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    export INGRESSGATEWAY=istio-ingressgateway
fi

kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"
```

## Local DNS setup

You can map the domain to the IP address of your Knative gateway in your local
machine with:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

export GATEWAY_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system --output jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`

# helloworld-go is the generated Knative Route of "helloworld-go" sample.
# You need to replace it with your own Route in your project.
export DOMAIN_NAME=`kubectl get route helloworld-go --output jsonpath="{.status.domain}"`

# Add the record of Gateway IP and domain name into file "/etc/hosts"
echo -e "$GATEWAY_IP\t$DOMAIN_NAME" | sudo tee -a /etc/hosts

```

You can now access your domain from the browser in your machine and do some
quick checks.

## Publish your Domain

Follow these steps to make your domain publicly accessible:

### Set static IP for Knative Gateway

You might want to
[set a static IP for your Knative gateway](gke-assigning-static-ip-address/),
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

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
