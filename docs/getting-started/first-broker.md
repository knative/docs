## Sources, Brokers, Triggers, Sinks, oh my!

For the purposes of this tutorial, let's keep it simple. You will focus on three powerful Eventing components: `Source`, `Trigger` and `Broker`. We'll then bring this all together by using a Knative Service as a `Sink` for our CloudEvents.


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


## Examining the Broker
As part of the `KonK` install, you should have an in-memory `Broker` already installed.
```bash
kn broker list
```

==**Expected Output**==
```{ .bash .no-copy }
NAME             URL                                                                          AGE   CONDITIONS   READY   REASON
example-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/default     5m    5 OK / 5     True    
```
!!! warning
    In-Memory Brokers are for development use only and must not be used in a production deployment.


??? question "What other components exist in Knative Eventing?"
    If you want to find out more about the different components of Knative Eventing, like Channels, Sequences, Parallels, etc. check out <a href="../eventing/README.md" target="blank_">"Eventing Components."</a>
