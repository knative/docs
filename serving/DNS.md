# Use a Custom Domain

By default, Knative Serving routes use `demo-domain.com` as the default domain.
The FDQN for a route by default is `{route}.{namespace}.{default-domain}`.

To change the {default-domain} value there are a few steps involved:

## Edit using kubectl

1. Edit the domain configuration config-map to replace `demo-domain.com` 
   with your own customer domain, for example `knative.dev`:

```shell
kubectl edit cm config-domain -n knative-serving
```

This will open your default text editor and allow you to edit the config map. 

```yaml
apiVersion: v1
data:
  # These are example settings of domain.
  # prod-domain.com will be used for routes having app=prod.
  prod-domain.com: |
    selector:
      app: prod

  # Default value for domain, for routes that does not have app=prod labels.
  # Although it will match all routes, it is the least-specific rule so it
  # will only be used if no other domain matches.
  demo-domain.com: |
```

Edit the file to replace `demo-domain.com` with the new domain you wish to use 
and save your changes:

```yaml
apiVersion: v1
data:
  # These are example settings of domain.
  knative.app: |
    selector:
      app: prod

  # Default value for domain, for routes that does not have app=prod labels.
  # Although it will match all routes, it is the least-specific rule so it
  # will only be used if no other domain matches.
  knative.dev: |
```

## Apply from a file

You can also apply an updated domain configuration config-map:

1. Create a new file, `config-domain.yaml` and paste the following text,
   replacing the `prod-domain.com` and `demo-domain.com` values with the new
   domain you want to use:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-domain
      namespace: knative-serving
    data:
      # These are example settings of domain.
      # prod-domain.com will be used for routes having app=prod.
      prod-domain.com: |
        selector:
          app: prod
      # Default value for domain, for routes that does not have app=prod labels.
      # Although it will match all routes, it is the least-specific rule so it
      # will only be used if no other domain matches.
      demo-domain.com: |
    ```

2. Apply updated domain configuration to your cluster:

    ```shell
    kubectl apply -f config-domain.yaml
    ```

## Deploy an application

> If you have an existing deployment, Knative will reconcile the change made to
> the configuration map and automatically update the host name for all deployed
> services and routes.


Deploy an app to your cluster as normal. For example, if you use the 
[`helloworld-go`](./samples/helloworld-go/README.md) sample app, when the 
ingress is ready, you'll see customized domain in HOSTS field together with 
assigned IP address:

```shell
$ kubectl get ingress

NAME                    HOSTS                                                                   ADDRESS        PORTS     AGE
helloworld-go-ingress   helloworld-go.default.knative.dev,*.helloworld-go.default.knative.dev   35.237.28.44   80        2m
```

## Update your DNS records

To enable the new custom domain to work in a browser, you need to update your
DNS provider to point to the IP address for your service ingress.

* Create an A record to point from the FDQN (shown as HOSTS in the ingress 
  output) to the IP address listed:
  
    ```dns
    helloworld-go.default.         59     IN     A   35.237.28.44
    ```

* Create a [wildcard record](https://support.google.com/domains/answer/4633759)
  for the namespace and custom domain to the ingress IP Address. This will 
  enable hostnames for multiple services in the same namespace to work without
  creating additional DNS entries.

    ```dns
    *.default.                   59     IN     A   35.237.28.44
    ```

If you are using Google Cloud DNS, you can find step-by-step instructions
in the [Cloud DNS quickstart](https://cloud.google.com/dns/quickstart).


Once the domain update has propigated, you can then access your app using 
the FQDN of the deployed route, for example
`http://helloworld-go.default.knative.dev`
