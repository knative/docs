## Creating your first Source
Now that we have a `Broker`, let's send some CloudEvents to using a `Source`.

A `Source` is Kubernetes custom resource (CR) that emits CloudEvents to a specified location (in our case, a `Broker`). Basically, a `Source` is exactly what it sounds like: it's a "source" of CloudEvents.

You can check the current state of sources in your deployment by running the following command:

```bash
    kn source list
```

You should get:
```bash
    No sources found.
```

You haven't deployed any `Sources` to your Knative deployment, so there shouldn't be any present when `kn` checks for them. **Let's remedy this by creating our first Knative `Source`.**
```bash
    kn service create cloudevents-player \
    --image ruromero/cloudevents-player:latest \
    --env BROKER_URL=<broker-url>
```
Where `<broker-url>` is the URL of your In-Memory Broker which we discovered in the previous step.

You should get:
```bash
    ... 'cloudevents-player-xxxxx-``' is available at URL: <service-url>
```
Where `<service-url>` is the location where your Knative Service is hosted.

The [CloudEvents Player](https://github.com/ruromero/cloudevents-player) is a very useful web app that we can use to send and receive CloudEvents. If you open this url in your browser, you should be greeted by a slick UI which includes a form titled "Create Event."

## Sending your first CloudEvent
In the "Create Event" form, we are greeted by a number of fields, all of which are required.

| Field          | Description |
|----------------|-------------|
| `Event ID`     | A unique ID (generally a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier#:~:text=A%20universally%20unique%20identifier%20(UUID,%2C%20for%20practical%20purposes%2C%20unique.)). Click the loop icon to generate a new one.   |
| `Event Type`   | An event type.|
| `Event Source` | An event source.|
| `Specversion`  | Demarcates which CloudEvents spec you're using (should always be 1.0).|
| `Message`      | The `data` section of the CloudEvent, a payload which is carrying the data you care to be delivered.|

Fill out the form with whatever you data you would like to and hit the "SEND EVENT" button.

You should see this:
![screencapture-cloudevents-player-default-127-0-0-1-nip-io-2021-04-14-07_42_26](https://user-images.githubusercontent.com/16281246/114704777-fcabc180-9cf4-11eb-8cd8-ae85ca32101e.png)

!!! tip Clicking the :fontawesome-solid-envelope: will show you the CloudEvent as the `Broker` sees it.

The :material-send: icon in the "Status" column implies that the event has been sent to our `Broker` which we specified through the environment variable `BROKER_URL`. But where has the event gone? Well, right now, nowhere!

A `Broker` is simply a receptacle for events. In order for your events to be sent somewhere, you must create a `Trigger` which listens for your events and places them somewhere.

## Creating your first `Trigger`
A [`Trigger`](../eventing/triggers/) represents a desire to subscribe to events from a specific broker.

If, for example, you wanted to intake the CloudEvents our CloudEvents Player was emitting to our `Broker` you could create a `Trigger`, like so:

```bash
    kn trigger create cloudevents-player --sink cloudevents-player
```
Notice that you specified a `Sink` in the creation of our `Trigger` which tells Knative where to put the Events this `Trigger` is listening for.

You should see:
```bash
Trigger 'cloudevents-player' successfully created in namespace 'default'.
```

??? question "What CloudEvents is my `Trigger` listening for?"
    Since we didn't specify a `--filter` in our `kn` command, our Trigger is listening for any CloudEvents coming into the `Broker`.

Now, when we go back to the CloudEvents Player and send an Event, we see that CloudEvents are both sent and received:

![screencapture-cloudevents-player-default-127-0-0-1-nip-io-2021-04-14-07_39_08](https://user-images.githubusercontent.com/16281246/114704377-8909b480-9cf4-11eb-9db0-815223199b5b.png)


??? question "What if I want to filter on CloudEvent attributes?"
    First, delete your existing Trigger:
    ```bash
      kn trigger delete cloudevents-player
    ```
    Now let's add a Trigger that listens for a certain CloudEvent Type
    ```bash
      kn trigger create cloudevents-player --sink cloudevents-player --filter type=com.example
    ```

    If you send a CloudEvent with type "com.example," it will be reflected in the CloudEvents Player UI. Any other types will be ignored by the `Trigger`.

    You can filter on any aspect of the CloudEvent you would like to.

In review, you have created a Knative Service (the CloudEvents Player) as your `Source` of CloudEvents which are sent through the `Broker`, routed by the `Trigger` and received by that same Knative Service which is *also* acting as a `Sink` for CloudEvents.

??? info "Architecture Diagram"
    //TODO

Some people call this **"Event-Driven Architecture"** which can be used to create your own **"Functions as a Service"** on Kubernetes :tada: :taco: :fire:
