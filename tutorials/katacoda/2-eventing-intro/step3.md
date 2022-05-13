## Using Triggers and sinks
In the last topic we used the CloudEvents Player as an event source to send events to the Broker. 
We now want the event to go from the Broker to an event sink.

In this topic, we will use the CloudEvents Player as the sink as well as a source. 
This means we will be using the CloudEvents Player to both send and receive events. We will use a Trigger 
to listen for events in the Broker to send to the sink.


### Creating your first Trigger
Create a Trigger that listens for CloudEvents from the event source and places them into the sink, which is also the 
CloudEvents Player app.

To create the Trigger, run the command:
```sh
kn trigger create cloudevents-trigger --sink cloudevents-player  --broker example-broker

```{{execute}}

✅ **Expected output:**
```sh
Trigger 'cloudevents-trigger' successfully created in namespace 'default'.
```

> ❓ **What CloudEvents is my Trigger listening for?**
> Because we didn't specify a `--filter` in our `kn` command, the Trigger is listening for any 
> CloudEvents coming into the Broker.

### Sending an event and get it from CloudEvents
Send an Event again with a different ID:
```sh
curl -i http://cloudevents-player.default.example.com/messages \
    -H "Content-Type: application/json" \
    -H "Ce-Id: 111" \
    -H "Ce-Specversion: 1.0" \
    -H "Ce-Type: some-type" \
    -H "Ce-Source: command-line" \
    -d '{"msg":"Hello CloudEvents!"}'
```{{execute}}

✅ ** Expected output:**
```sh
HTTP/1.1 202 Accepted
content-length: 0
date: Fri, 29 Apr 2022 19:57:04 GMT
x-envoy-upstream-service-time: 4
server: envoy
```

Now list the messages in CloudEvents:
```sh
curl http://cloudevents-player.default.example.com/messages | jq
```{{execute}}

✅ ** Expected output:**
```sh
[
  {
    "event": {
      "attributes": {
        "datacontenttype": "application/json",
        "id": "111",
        "mediaType": "application/json",
        "source": "command-line",
        "specversion": "1.0",
        "type": "some-type"
      },
      "data": {
        "msg": "Hello CloudEvents!"
      },
      "extensions": {}
    },
    "id": "111",
    "receivedAt": "2022-04-29T23:54:51.956189+02:00[Europe/Madrid]",
    "type": "RECEIVED"
  },
  {
    "event": {
      "attributes": {
        "datacontenttype": "application/json",
        "id": "111",
        "mediaType": "application/json",
        "source": "command-line",
        "specversion": "1.0",
        "type": "some-type"
      },
      "data": {
        "msg": "Hello CloudEvents!"
      },
      "extensions": {}
    },
    "id": "111",
    "receivedAt": "2022-04-29T23:54:51.932247+02:00[Europe/Madrid]",
    "type": "SENT"
  }
]
```
Note that you have two records in the list, one for the SENT message and the other for the RECEIVED message.

❓ **What if I want to filter on CloudEvent attributes?**
First, delete your existing Trigger:
```sh
kn trigger delete cloudevents-trigger
```{{execute}}

Now let's add a Trigger that listens for a certain CloudEvent Type

```sh
kn trigger create cloudevents-player-filter --sink cloudevents-player  --broker example-broker --filter type=some-type

```{{execute}}

If you send a CloudEvent with type `some-type`, it is reflected in the CloudEvents Player. 
The Trigger ignores any other types.

Let us send another event with a different type `other-type`:
```sh
curl -i http://cloudevents-player.default.example.com/messages \
    -H "Content-Type: application/json" \
    -H "Ce-Id: 222" \
    -H "Ce-Specversion: 1.0" \
    -H "Ce-Type: other-type" \
    -H "Ce-Source: command-line" \
    -d '{"msg":"Hello CloudEvents!"}'
```{{execute}}

When you list the messages again you can see that the message id 222 was SENT but not RECEIVED.
```sh
curl http://cloudevents-player.default.example.com/messages | jq
```{{execute}}
✅ ** Expected output:**
```sh
[
  {
    "event": {
      "attributes": {
        "datacontenttype": "application/json",
        "id": "222",
        "mediaType": "application/json",
        "source": "command-line",
        "specversion": "1.0",
        "type": "other-type"
      },
      "data": {
        "msg": "Hello CloudEvents!"
      },
      "extensions": {}
    },
    "id": "222",
    "receivedAt": "2022-04-29T23:56:23.983083+02:00[Europe/Madrid]",
    "type": "SENT"
  }
]
```

You can filter on any aspect of the CloudEvent you would like to.


Some people call this "Event-Driven Architecture" which can be used to create your own "Functions as a Service" 
on Kubernetes 🎉 🌮 🔥
