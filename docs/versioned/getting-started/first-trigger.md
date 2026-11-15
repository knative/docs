---
audience: developer
components:
  - eventing
function: tutorial
hide_prev: true
hide_next: true
---

<span id="using-triggers-and-sinks"></span><span id="creating-your-first-trigger"></span>

# Filter events by type

This lesson is optional. Start with the working CloudEvents Player, Broker, and
`cloudevents-trigger` from [Send and receive an event](first-source.md).
You will change which events the existing Trigger delivers.

## Add a type filter

```bash
kn trigger update cloudevents-trigger --filter type=dev.knative.tutorial
kn trigger list
```

Wait for the Trigger to be ready. It now matches only events whose `type`
attribute is exactly `dev.knative.tutorial`.

## Send matching and non-matching events

In the player's browser form:

1. Send an event with type `dev.knative.tutorial` and a new Event ID.
2. Confirm that the event appears as both sent and received.
3. Send another event with type `dev.knative.other` and a different Event ID.
4. Check that the second event appears as sent, but is not delivered back through
   this Trigger. Check new Event IDs rather than mistaking earlier received events
   for this test.

The filter selects events; it does not change their contents. Other Triggers on
the Broker, if present, make their own independent selections.

## Remove the filter

Restore the original behavior before continuing with other experiments:

```bash
kn trigger update cloudevents-trigger --filter type-
```

This removes the `type` filter, allowing the Trigger to match all events again.

<span id="next-steps"></span>

## Finish the track

You have routed events and selected them by type. [Continue learning](next-steps.md)
with another track, or use the [Eventing guides](../eventing/README.md) for your
own application. Delete the learning cluster only when you no longer need it.
