# Sources, Brokers, and Triggers

As part of the `kn quickstart` install, an InMemoryChannel-backed Broker is installed on your kind cluster.

Verify that the Broker is installed by running the following command:

```bash
kn broker list
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME             URL                                                                                AGE   CONDITIONS   READY   REASON
    example-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker     5m    5 OK / 5    True
    ```
!!! warning
    InMemoryChannel-backed Brokers are for development use only and must not be used in a production deployment.

**Next, you'll take a look at a simple implementation** of Sources, Brokers, Triggers and Sinks using an app called the CloudEvents Player.
