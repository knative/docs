## Sources, Brokers, Triggers, Sinks, oh my!
For the purposes of this tutorial, let's keep it simple. You will focus on four powerful Eventing components: Source, Trigger, Broker, and Sink.

Let's take a look at how these components interact:
<figure>
  <img src="https://user-images.githubusercontent.com/16281246/116248768-1fe56080-a73a-11eb-9a85-8bdccb82d16c.png" draggable="false">
  <figcaption> Source 1 and Source 2 are transmitting some data (1's and 2's) to the Broker, which then gets filtered by Triggers to the desired Sink.</figcaption>
</figure>

| Component      | Basic Definition                          |
| :---------: | :----------------------------------: |
|:material-information: **Source**       |A Kubernetes Custom Resource which emits events to the Broker. |
|:material-relation-many-to-many: **Broker**       | A "hub" for events in your infrastructure; a central location to send events for delivery. |
|:material-magnet: **Trigger** |Acts as a filter for events entering the broker, can be configured with desired event attributes. |
|:material-download: **Sink** | A destination for events. |

!!! note "A note on Sources and Sinks"
    A Knative Service can act as both a Source and a Sink for events, and for good reason. You may want to consume events from the Broker and send modified events back to the Broker, as you would in any pipeline use-case.

### CloudEvents
Knative Eventing uses <a href="https://github.com/cloudevents/spec/blob/master/primer.md" target="blank_">CloudEvents</a> to send information back and forth between your Services and these components.

??? question "What are CloudEvents?"
    For our purposes, the only thing you need to know about CloudEvents are:

    1. CloudEvents can carry some attributes (like id, Source, type, etc) as well as data payloads (JSON, plaintext, reference to data that lives elsewhere, etc).
    1. CloudEvents can be "emitted" by almost anything and can be transported to anywhere in your deployment.
    1. CloudEvents follow the <a href = "https://github.com/cloudevents/spec" target="_blank">CloudEvents 1.0 Specification</a>, with required and optional attributes.


    To find out more about CloudEvents, check out the [CloudEvents website](https://cloudevents.io/)!


## Examining the Broker
As part of the `KonK` install, an In-Memory Broker should have already be installed in your Cluster. Check to see that it is installed by running the command:

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


??? question "Are there any other components of Knative Eventing?"
    Though it is out of scope for this tutorial, Knative Eventing has many components which can be used in many ways to suit your needs.

    If you want to find out more about the different components of Knative Eventing, such as Channels, Sequences and Parallel flows, check out <a href="../../eventing/README.md" target="blank_">"Eventing Components."</a>

**Next, you'll take a look at a simple implementation** of Sources, Brokers, Triggers and Sinks using an app called the Cloud Events Player.
