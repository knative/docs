=== "Real DNS"

    To configure DNS for Knative, take the External IP
    or CNAME from setting up networking, and configure it with your DNS provider as
    follows:

    - If the networking layer produced an External IP address, then configure a
      wildcard `A` record for the domain:

      ```
      # Here knative.example.com is the domain suffix for your cluster
      *.knative.example.com == A 35.233.41.212
      ```

    - If the networking layer produced a CNAME, then configure a CNAME record for the domain:

      ```
      # Here knative.example.com is the domain suffix for your cluster
      *.knative.example.com == CNAME a317a278525d111e89f272a164fd35fb-1510370581.eu-central-1.elb.amazonaws.com
      ```

    - Once your DNS provider has been configured, add the following section into your existing Serving CR, and apply it:

      ```yaml
      # Replace knative.example.com with your domain suffix
      apiVersion: operator.knative.dev/v1alpha1
      kind: KnativeServing
      metadata:
        name: knative-serving
        namespace: knative-serving
      spec:
        config:
          domain:
            "knative.example.com": ""
        ...
      ```
