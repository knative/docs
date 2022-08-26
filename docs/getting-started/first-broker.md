# Sources, Brokers, and Triggers

As part of the `kn quickstart` install, an In-Memory Broker should already be installed in your Cluster. Check to see that it is installed by running the command:

```bash
kn broker list
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME             URL                                                                                AGE   CONDITIONS   READY   REASON
    example-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker     5m    5 OK / 5    True
    ```
!!! warning
    In-Memory Brokers are for development use only and must not be used in a production deployment.

**Next, you'll take a look at a simple implementation** of Sources, Brokers, Triggers and Sinks using an app called the CloudEvents Player.
