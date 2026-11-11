---
audience: developer
components:
  - eventing
function: tutorial
---

# Sources, Brokers, and Triggers

**Starting state:** You have completed [Quickstart installation](quickstart-install.md) and are using its kind cluster in `default`. The plugin installs an InMemoryChannel-backed Broker implementation and provides an example Broker for this exercise.

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

If `example-broker` is absent, create it on this Quickstart cluster with `kn broker create example-broker`, then run `kn broker list` again. If it is present but not Ready, inspect `kubectl describe broker example-broker` and resolve its status before continuing. The cluster must have the Broker implementation installed; creating a Broker alone does not install it.

**Previous:** [Eventing learning route](getting-started-eventing.md) · **Next:** [Send an event with the CloudEvents Player](first-source.md)
