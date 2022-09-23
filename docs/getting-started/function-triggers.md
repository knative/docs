# Triggers, Brokers, and Event Sources

Functions can be invoked by Knative event sources using triggers. Now you will
create a trigger that will invoke your function when a CloudEvent is emitted by
a PingSource.

## Create a Broker

First, let's create a Broker. A Broker is a resource that will receive events
from the Ping Source. The Broker will then forward those events to the Trigger
which, in turn, will invoke the function. For many of the following commands,
you will use the `kn` CLI.

=== "func"

    Create a default Broker by running the command:

    ```bash
    kn broker create default
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
          Broker 'default' successfully created in namespace 'default'.
        ```

## Create a PingSource

To create the PingSource, you can also use the `kn` CLI. This command will
result in a PingSource emitting an event every minute, sending it to the
default Broker.

=== "func"

    Create a PingSource by running the command:

    ```bash
    kn source ping create ping --sink broker:default --schedule="*/1 * * * *"
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
        Ping source 'ping' created in namespace 'default'.
        ```

## Create a Trigger

Now that the Broker and PingSource are created, you can create a Trigger that
will forward PingSource events to the function.

=== "func"

    Create a Trigger by running the command:

    ```bash
    kn trigger create ping-trigger -s hello
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
        Trigger 'ping-trigger' successfully created in namespace 'default'.
        ```

To see your function being invoked, you can use the `kubectl` CLI to watch the
logs of the function pod. Watch the logs of the function pod by running the command:

=== "func"
    ```bash
    kubectl logs -l function.knative.dev=true --tail=10
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
        Received event
        Context Attributes,
          specversion: 1.0
          type: dev.knative.sources.ping
          source: /apis/v1/namespaces/default/pingsources/ping
          id: d467df81-3296-48ed-bb1c-0662153f53b1
          time: 2022-09-23T14:25:00.344067423Z
        Extensions,
          knativearrivaltime: 2022-09-23T14:25:01.295357548Z
        ```
