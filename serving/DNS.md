# Use a Custom Domain

By default, Knative Serving routes use `example.com` as the default domain.
The fully qualified domain name for a route by default is `{route}.{namespace}.{default-domain}`.

To change the {default-domain} value there are a few steps involved:

## Edit using kubectl

1. Edit the domain configuration config-map to replace `example.com` 
   with your own customer domain, for example `knative.dev`:

```shell
kubectl edit cm config-domain -n knative-serving
```

This will open your default text editor and allow you to edit the config map. 

```yaml
apiVersion: v1
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
kind: ConfigMap
[...]
```

Edit the file to replace `example.com` with the new domain you wish to use 
and save your changes. In this example, we configure `knative.dev` for all routes: 

```yaml
apiVersion: v1
data:
  knative.dev: ""
kind: ConfigMap
[...]
```

## Apply from a file

You can also apply an updated domain configuration config-map:

1. Create a new file, `config-domain.yaml` and paste the following text,
   replacing the `example.org` and `example.com` values with the new
   domain you want to use:

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

2. Apply updated domain configuration to your cluster:

    ```shell
    kubectl apply -f config-domain.yaml
    ```

## Deploy an application

> If you have an existing deployment, Knative will reconcile the change made to
> the configuration map and automatically update the host name for all deployed
> services and routes.


Deploy an app, for example, [`helloworld-go`](./samples/helloworld-go/README.md
) sample, to your cluster as normal. You can check the customized domain in 
Knative Route "helloworld-go" with
```shell
kubectl get route helloworld-go -o jsonpath="{.status.domain}"
```
You should see the full customized domain is `helloworld-go.default.knative.dev`.

And you can check the IP address of Knative gateway with
```shell
kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*]['ip']}"
```

## Local DNS setup

You can map the domain to the IP address of Knative Gateway in your local 
machine with:
```shell
export GATEWAY_IP=`kubectl get svc knative-ingressgateway -n istio-system -o jsonpath="{.status.loadBalancer.ingress[*]['ip']}"`

# helloworld-go is the generated Knative Route of "helloworld-go" sample.
# You need to replace it with your own Route in your project.
export DOMAIN_NAME=`kubectl get route helloworld-go -o jsonpath="{.status.domain}"`

# Add the record of Gateway IP and domain name into file "/etc/hosts"
echo -e "$GATEWAY_IP\t$DOMAIN_NAME" | sudo tee -a /etc/hosts

```
By this way, you can access your domain from the browser in your machine and
 do some quick checks.

## Publish your Domain

Follow the below steps to make your domain publicly accessible.

### Set static IP for Knative Gateway

You may want to set static IP for your Knative Gateway so that the Gateway IP 
will not be changed after restarting your cluster.
Follow the [instructions](https://github.com/knative/serving/blob/master/docs/setting-up-ingress-static-ip.md) to set static IP for Knative Gateway.

### Update your DNS records

To publish your domain, you need to update your DNS provider to point to the 
IP address for your service ingress.

* Create an A record to point from the fully qualified domain name to the IP address of Knative Gateway.
  
    ```dns
    helloworld-go.default.knative.dev        59     IN     A   35.237.28.44
    ```

* Create a [wildcard record](https://support.google.com/domains/answer/4633759)
  for the namespace and custom domain to the ingress IP Address. This will enable hostnames for multiple services in the same namespace to work without
  creating additional DNS entries.

    ```dns
    *.default.knative.dev                   59     IN     A   35.237.28.44
    ```

If you are using Google Cloud DNS, you can find step-by-step instructions
in the [Cloud DNS quickstart](https://cloud.google.com/dns/quickstart).


Once the domain update has propagated, you can then access your app using 
the fully qualified domain name of the deployed route, for example
`http://helloworld-go.default.knative.dev`
