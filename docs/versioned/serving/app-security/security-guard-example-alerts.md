
# Security-Guard example alerts

1. Send an event with unexpected query string, for example:

     ```bash
     curl "http://helloworld-go.default.52.118.14.2.sslip.io?a=3"
     ```

     This returns an output similar to the following:

     ```sh
     Hello Secured World!
     ```

1. Check alerts:

     ```bash
     kubectl logs deployment/helloworld-go-00001-deployment queue-proxy|grep "SECURITY ALERT!"
     ```

     This returns an output similar to the following:

     ```sh
     ...SECURITY ALERT! HttpRequest -> [QueryString:[KeyVal:[Key a is not known,],],]
     ```

1. Send an event with unexpected long url, for example:

     ```bash
     curl "http://helloworld-go.default.52.118.14.2.sslip.io/AAAAAAAAAAAAAAAA"
     ```

     This returns an output similar to the following:

     ```sh
     Hello Secured World!
     ```

1. Check alerts:

     ```bash
     kubectl logs deployment/helloworld-go-00001-deployment queue-proxy|grep "SECURITY ALERT!"
     ```

     This returns an output similar to the following:

     ```sh
     ...SECURITY ALERT! HttpRequest -> [Url:[Segments:[Counter out of Range: 1,],Val:[Letters:[Counter out of Range: 16,],Sequences:[Counter out of Range: 1,],],],].
     ```
