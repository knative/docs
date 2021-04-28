# Introducing the CloudEvents Player

## Background
With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease. **With Knative Eventing, you gain a few new super powers :rocket: that allow you to build Event-Driven Applications.**

??? question "What are Event Driven Applications?"
    Event-driven applications are designed to detect events as they occur, and then deal with them using some event-handling procedure. Producing "events" to detect and consuming events with an "event-handling procedure" is precisely what Knative Eventing enables.

Knative Eventing acts as the "glue" between the disparate parts of your architecture and allows you to easily communicate between those parts in a fault-tolerant way. Some examples include: [creating and responding to Kubernetes API events](../../eventing/sources/apiserversource/), [creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ), or [facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s).

## Sources, Brokers, Triggers, Sinks, oh my!
For the purposes of this tutorial, we'll keep it simple. You will focus on four components for building this communication infrastructure **(`Source`, `Trigger`, `Broker`, and `Sink`)**.

<figure>
  <img src="https://user-images.githubusercontent.com/16281246/116248768-1fe56080-a73a-11eb-9a85-8bdccb82d16c.png" draggable="false">
  <figcaption>A basic implementation</figcaption>
</figure>


Knative Eventing uses <a href="https://github.com/cloudevents/spec/blob/master/primer.md" target="blank_">CloudEvents</a> send information back and forth between your Services and these components.

??? question "What our CloudEvents?"
    For our purposes, the only thing you need to know about CloudEvents are:

    1. CloudEvents follow the <a href = "https://github.com/cloudevents/spec" target="_blank">CloudEvents 1.0 Specification</a>, with required and optional attributes.
    1. CloudEvents can be "emitted" by almost anything and can be transported to anywhere in your deployment.  
    1. CloudEvents can carry some attributes (things like `id`, `source`, `type`, etc) as well as data payloads (JSON, plaintext, reference to data that lives elsewhere, etc).

    ??? question "Want to find out more about CloudEvents?"
        Check out the [CloudEvents website](https://cloudevents.io/)!


??? question "What other components exist in Knative Eventing?"
    If you want to find out more about the different components of Knative Eventing, like Channels, Sequences, Parallels, etc. check out <a href="../eventing/README.md" target="blank_">"Eventing Components."</a>
