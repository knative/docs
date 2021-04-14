# Getting Started with Knative Eventing
## Background
**With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease.**

Nowadays, modern infrastructure demands we deploy many services to do many different things and, often times, these services have dependency on one another. *Your hypothetical "Inventory Management" Knative Service would like to know when your "Point-Of-Sale" Knative Service preforms an action (i.e. makes a sale) so it can preform its own relevant actions.*

Knative Eventing provides the basis for communicating these sorts of actions, whether those actions are coming from within your Kubernetes deployment or from some outside source. **For the purposes of this tutorial, we will focus on four components for building this communication infrastructure (`Source`, `Trigger`, `Broker`, and `Sink`)**, but there are many other tools in the Knative Eventing toolbox which can be used to create your own "Functions as a Service" (FaaS) on top of Kubernetes.

??? question "What other components exist in Knative Eventing?"
    If you want to find out more about the different components of Knative Eventing, like Channels, Sequences, Parallels, etc. check out the ["Eventing Components."](../eventing/README.md)


## Introducing CloudEvents
As the name suggests, Knative Eventing communicates these actions in the form of "Events" and the format Knative uses for these Events is <a href="https://github.com/cloudevents/spec/blob/master/primer.md" target="blank_">CloudEvents</a>.

For our purposes, the only thing you need to know about CloudEvents are:

1. CloudEvents follow a specification (a specific format), with required and optional attributes.
1. CloudEvents can be "emitted" (created) by almost anything. This includes Knative Services, as well as data sources that exist outside of your Kubernetes deployment.
1. CloudEvents can carry some attributes (things like `id`, `source`, `type`, etc) as well as payloads (JSON, plaintext, reference to data that lives elsewhere, etc).

??? question "Want to find out more about CloudEvents?"
    Check out the [CloudEvents website](https://cloudevents.io/)!
