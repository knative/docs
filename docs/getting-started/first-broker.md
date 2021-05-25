## Sources, Brokers, Triggers, Sinks, oh my!
For the purposes of this tutorial, let's keep it simple. You will focus on four powerful Eventing components: `Source`, `Trigger`, `Broker`, and `Sink`.

Let's take a look at how these components interact:
<figure>
  <img src="https://user-images.githubusercontent.com/16281246/116248768-1fe56080-a73a-11eb-9a85-8bdccb82d16c.png" draggable="false">
  <figcaption> Source 1 and Source 2 are transmitting some data (1's and 2's) to the Broker, which then gets filtered by Triggers to the desired Sink.</figcaption>
</figure>

| Component      | Basic Definition                          |
| :---------: | :----------------------------------: |
| `Source`       | :information_source:  A Kubernetes Custom Resource which emits events to the Broker. |
| `Broker`       | :material-relation-many-to-many: A "hub" for events in your infrastructure; a central location to send events for delivery. |
| `Trigger`    | :material-magnet-on: Acts as a filter for events entering the broker, can be configured with desired event attributes. |
| `Sink`    | :material-download:  A destination for events. |

!!! note "A note on `Sources` and `Sinks`"
    A Knative Service can act as both a `Source` and a `Sink` for events, and for good reason. You may want to consume events from the `Broker` and send modified events back to the `Broker`, as you would in any pipeline use-case.

### CloudEvents
Knative Eventing uses <a href="https://github.com/cloudevents/spec/blob/master/primer.md" target="blank_">CloudEvents</a> send information back and forth between your Services and these components.

??? question "What are CloudEvents?"
    For our purposes, the only thing you need to know about CloudEvents are:

    1. CloudEvents follow the <a href = "https://github.com/cloudevents/spec" target="_blank">CloudEvents 1.0 Specification</a>, with required and optional attributes.
    1. CloudEvents can be "emitted" by almost anything and can be transported to anywhere in your deployment.  
    1. CloudEvents can carry some attributes (things like `id`, `source`, `type`, etc) as well as data payloads (JSON, plaintext, reference to data that lives elsewhere, etc).

    To find out more about CloudEvents, check out the [CloudEvents website](https://cloudevents.io/)!


## Examining the Broker
As part of the `KonK` install, you should have an in-memory `Broker` already installed.
```bash
kn broker list
```

==**Expected Output**==
```{ .bash .no-copy }
NAME             URL                                                                                AGE   CONDITIONS   READY   REASON
example-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker     5m    5 OK / 5    True
```
!!! warning
    In-Memory Brokers are for development use only and must not be used in a production deployment.


??? question "What other components exist in Knative Eventing?"
    If you want to find out more about the different components of Knative Eventing, like Channels, Sequences, Parallels, etc. check out <a href="../eventing/README.md" target="blank_">"Eventing Components."</a>
