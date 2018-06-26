## Custom Domain

Knative uses `demo-domain.com` as default domain; To use your own customized domain, there are a few steps involved.

1. Change [domain configuration](/config/config-domain.yaml) to replace `demo-domain.com` with your own domain name, for example, `foo.com`.

```
data:
  # These are example settings of domain.
  # prod-domain.com will be used for routes having app=prod.
  prod-domain.com: |
    selector:
      app: prod
  # Default value for domain, for routes that does not have app=prod labels.
  # Although it will match all routes, it is the least-specific rule so it
  # will only be used if no other domain matches.
  foo.com: |
```

2. Apply updated domain configuration.

  ```shell
  kubectl apply -f config/config-domain.yaml
  ```

3. [Deploy app normally](./samples/helloworld-go/README.md) assuming it is `helloworld-go` sample app you are deploying. When the ingress is ready, you'll see customized domain in HOSTS field together with assigned IP address.

```
NAME                    HOSTS                                                                       ADDRESS        PORTS     AGE
helloworld-go-ingress   helloworld-go.default.foo.com,*.helloworld-go.default.foo.com   35.237.28.44   80        2m
```

4. Update DNS to point HOSTS to IP address.

    1. If the domain is not registered with Google, you need to [update the NS records for your domain with your registrar](https://cloud.google.com/dns/update-name-servers).
    1. Create A record via [GCP DNS](https://pantheon.corp.google.com/net-services/dns) to map `route-example.default.foo.com` to `35.237.28.44`; Step by step instruction is [here](https://cloud.google.com/dns/quickstart).

5. You should be able to access `http://route-example.default.foo.com` from browser. It may take a while for the above update to take effect though.
