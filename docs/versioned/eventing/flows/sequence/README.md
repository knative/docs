# Sequence

Sequence CRD provides a way to define an in-order list of functions that will be
invoked. Each step can modify, filter or create a new kind of an event. Sequence
creates `Channel`s and `Subscription`s under the hood.

!!! info
    Sequence needs "hairpin" traffic. Please verify that your pod can reach itself via the service IP.
    If the "hairpin" traffic is not available, you can reach out to your cluster administrator since its a cluster level (typically CNI) setting.


## Usage

### Sequence Spec

Sequence has three parts for the Spec:

1. `Steps` which defines the in-order list of `Subscriber`s, aka, which
   functions are executed in the listed order. These are specified using the
   `messaging.v1.SubscriberSpec` just like you would when creating
   `Subscription`. Each step should be `Addressable`.
1. `ChannelTemplate` defines the Template which will be used to create
   `Channel`s between the steps.
1. `Reply` (Optional) Reference to where the results of the final step in the
   sequence are sent to.

### Sequence Status

Sequence has four parts for the Status:

1. Conditions which detail the overall Status of the Sequence object
1. ChannelStatuses which convey the Status of underlying `Channel` resources
   that are created as part of this Sequence. It is an array and each Status
   corresponds to the Step number, so the first entry in the array is the Status
   of the `Channel` before the first Step.
1. SubscriptionStatuses which convey the Status of underlying `Subscription`
   resources that are created as part of this Sequence. It is an array and each
   Status corresponds to the Step number, so the first entry in the array is the
   `Subscription` which is created to wire the first channel to the first step
   in the `Steps` array.
1. AddressStatus which is exposed so that Sequence can be used where Addressable
   can be used. Sending to this address will target the `Channel` which is
   fronting the first Step in the Sequence.

## Examples

For each of the following examples, you use a [`PingSource`](../../../eventing/sources/ping-source/README.md) as the source of events.

We also use a very simple [transformer](https://github.com/knative/eventing/blob/main/cmd/appender/main.go) which performs very trivial transformation of the incoming events to demonstrate they have passed through each stage.

### Sequence with no reply

For the first example, we'll use a 3 Step `Sequence` that is wired directly into
the `PingSource`. Each of the steps simply tacks on "- Handled by
<STEP NUMBER>", for example the first Step in the `Sequence` will take the
incoming message and append "- Handled by 0" to the incoming message.

See [Sequence with no reply (terminal last Step)](../sequence/sequence-terminal/README.md).

### Sequence with reply

For the next example, we'll use the same 3 Step `Sequence` that is wired
directly into the `PingSource`. Each of the steps simply tacks on "- Handled
by <STEP NUMBER>", for example the first Step in the `Sequence` will take the
incoming message and append "- Handled by 0" to the incoming message.

The only difference is that we'll use the `Subscriber.Spec.Reply` field to wire
the output of the last Step to an event display pod.

See [Sequence with reply (last Step produces output)](../sequence/sequence-reply-to-event-display/README.md).

### Chaining Sequences together

For the next example, we'll use the same 3 Step `Sequence` that is wired
directly into the `PingSource`. Each of the steps simply tacks on "- Handled
by <STEP NUMBER>", for example the first Step in the `Sequence` will take the
incoming message and append "- Handled by 0" to the incoming message.

The only difference is that we'll use the `Subscriber.Spec.Reply` field to wire
the output of the last Step to another `Sequence` that does the same message
modifications as the first pipeline (with different steps however).

See [Chaining Sequences together](../sequence/sequence-reply-to-sequence/README.md).

### Using Sequence with Broker/Trigger model

You can also create a Trigger which targets `Sequence`. This time we'll wire
`PingSource` to send events to a `Broker` and then we'll have the `Sequence`
emit the resulting Events back into the Broker so that the results of the
`Sequence` can be observed by other Triggers.

See [Using Sequence with Broker/Trigger model](../sequence/sequence-with-broker-trigger/README.md).
