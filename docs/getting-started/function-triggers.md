# Triggers, Brokers, and Event Sources

In the first Functions tutorial, you created a basic function that could receive
and respond to HTTP requests. Now, let's create a new function that can respond
to CloudEvents that are sent by Knative Eventing resources. In this tutorial, you
will create a simple Knative Event Source to generate CloudEvents, a Knative Broker
to send and receive these events, and a Knative Trigger to connect the event source
to your Knative Function. First, create and deploy the function.
## Create a CloudEvent Function

To create and deploy a CloudEvent function that echoes the CloudEvent it receives,
you can use the `kn func create` and `kn func deploy` commands.

Create the function by running the command:

```{ .console }
func create -l go -t cloudevents echo
```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Created go function in echo
    ```

And deploy the function with the `func deploy` command from within the project directory:

```{ .console}
cd echo
func deploy
```

!!! Success "Expected output"
    ```{ .console .no-copy }
      Received response
      Context Attributes,
        specversion: 1.0
        type: echo
        source: event.handler
        id: 3ac510fc-95f8-4958-a18e-3ffbff22c842
        time: 2022-09-23T12:45:23.981Z
        datacontenttype: application/json; charset=utf-8
      Data,
        {
          "id": "89f49b4c-c8c4-46d2-a99e-eeca44fa894b",
          "time": "2022-09-23T12:45:18.852Z",
          "type": "boson.fn",
          "source": "/boson/fn",
          "specversion": "1.0",
          "datacontenttype": "application/json",
          "data": {
            "message": "Hello World"
          }
        }
    ```

## Create a Broker

Now, let's create the Broker. A Broker is a resource that will receive events
from the Event Source. The Broker will then forward those events to the Trigger
which, in turn, will invoke the function. For many of the following commands,
you will use the `kn` CLI.

If you don't already have the `kn` CLI installed, please refer to the [Knative
Client installation instructions](https://knative.dev/docs/client/install-kn/).

Create a default Broker by running the command:

```{ .console }
kn broker create default
```

!!! Success "Expected output"
    ```{ .console .no-copy }
      Broker 'default' successfully created in namespace 'default'.
    ```

## Create a PingSource

A PingSource is a Knative Event Source that generates events at a specified interval.
To create the PingSource, you can also use the `kn` CLI. This command will
result in a PingSource emitting an event every minute, sending it to the
default Broker.

Create a PingSource called, `ping` by running the command:

```{ .console }
kn source ping create ping --sink broker:default --schedule="*/1 * * * *"
```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Ping source 'ping' created in namespace 'default'.
    ```

## Create a Trigger

Now that the Broker and PingSource are created, you can create a Trigger that
will forward all PingSource events to the function. In the following command,
the `--sink` flag specifies the function as the event destination for the event
source.

Create a Trigger by running the command:

```{ .console }
kn trigger create ping-trigger --sink hello
```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Trigger 'ping-trigger' successfully created in namespace 'default'.
    ```

To see your function being invoked, you can use the `kubectl` CLI to watch the
logs of the function pod. Watch the logs of the function pod by running the command:

```{ .console }
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
