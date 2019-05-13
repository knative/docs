# Event Filters in Triggers

Filters are used in Triggers to specify the set of events that are interesting
to a subscriber. If you only want to receive some events, and you know which
attributes identify the events you're interested in, use a filter in your
Trigger to ensure the Trigger's subscriber will receive only events that match
the filter.

## Before you begin

1.  Read about the [Broker and Trigger objects](./broker-trigger.md).
1.  Be familiar with the
    [CloudEvents spec](https://github.com/cloudevents/spec/blob/master/spec.md),
    particularly the
    [Context Attributes](https://github.com/cloudevents/spec/blob/master/spec.md#context-attributes)
    section.
1.  Read the
    [Common Expression Language introduction](https://github.com/google/cel-spec/blob/master/doc/intro.md),
    and optionally the
    [language definition](https://github.com/google/cel-spec/blob/master/doc/langdef.md).

## Filtering events

Events can be filtered in one of two ways: by **attributes** and by **expression**. Only
one of these filtering methods may be used per Trigger.

### Filtering by attributes



TODO "how to" info (the "task-oriented" step by step details for creating an
event filter in a trigger) -> use a gerund in title (for example Filtering event
attributes)

## Filter examples

### I want to receive events of a specific type

TODO Example(s) (show them how and where they would/can create a filter in their
trigger) i see lots in the proposal and it would be most consumable if we could
organize these to some degree

## Next steps

TODO Link to what the next logical step would be (and include links to related
info) to keep the user moving forward
