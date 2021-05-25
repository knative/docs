In this tutorial, you will be using the [CloudEvents Player](https://github.com/ruromero/cloudevents-player) to showcase the core concepts of Knative Eventing. By the end of this tutorial, you should have something that looks like this:

<figure>
  <img src="https://user-images.githubusercontent.com/16281246/116408922-589c3d00-a801-11eb-9835-5c37ff57c861.png" draggable="false">
  <figcaption>Figure 6.6 from <a href = "https://www.manning.com/books/knative-in-action" target="_blank">Knative in Action</a> <br>
Here, the CloudEvents Player is acting as both a <code>Source</code> and a <code>Sink</code> for CloudEvents.
  </figcaption>
</figure>

## Creating your first Source
The CloudEvents Player acts as a `Source` for CloudEvents by intaking the URL of our `Broker` as an environment variable (`BROKER_URL`) and sending CloudEvents via the UI.

Create the CloudEvents Player Service:
=== "kn"

    ```bash
    kn service create cloudevents-player \
    --image ruromero/cloudevents-player:latest \
    --env BROKER_URL=http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker
    ```

=== "YAML"

    ```bash
    //TODO
    ```

==**Expected Output**==
```{ .bash .no-copy }
Service 'cloudevents-player' created to latest revision 'cloudevents-player-vwybw-1' is available at URL:
http://cloudevents-player.default.127.0.0.1.nip.io
```
??? question "Wait, my `Revision` is named something different!"
    Since we didn't assign a `revision-name`, Knative Serving automatically created one for us, it's ok if your `Revision` is named something different.

## Examining the CloudEvents Player
We can use the CloudEvents Player to send and receive CloudEvents. If you open the [Service URL](http://cloudevents-player.default.127.0.0.1.nip.io){target=_blank} in your browser, you should be greeted by a form titled "Create event."

<figure>
  <img src="https://user-images.githubusercontent.com/16281246/116404278-7d41e600-a7fc-11eb-81a3-5f85db9f966a.png" draggable="false">
  <figcaption>The user interface for the CloudEvents Player</figcaption>
</figure>

??? question "What do these fields mean?"
    | Field          | Description |
    |:----------------:|:-------------|
    | `Event ID`     | A unique ID. Click the loop icon to generate a new one.   |
    | `Event Type`   | An event type.|
    | `Event Source` | An event source.|
    | `Specversion`  | Demarcates which CloudEvents spec you're using (should always be 1.0).|
    | `Message`      | The `data` section of the CloudEvent, a payload which is carrying the data you care to be delivered.|

    For more information on the CloudEvents Specification, check out the [CloudEvents Spec](https://github.com/cloudevents/spec/blob/v1.0.1/spec.md){target=_blank}.

Fill out the form with whatever you data you would like to (make sure your Event Source does not contain any spaces) and hit the "SEND EVENT" button.


![CloudEvents Player Send](https://user-images.githubusercontent.com/16281246/116407683-04448d80-a800-11eb-9283-ba86fb259053.png)


!!! tip "Tip: Clicking the :fontawesome-solid-envelope: will show you the CloudEvent as the `Broker` sees it."

The :material-send: icon in the "Status" column implies that the event has been sent to our `Broker`, but where has the event gone? Well, right now, nowhere!

A `Broker` is simply a receptacle for events. In order for your events to be sent somewhere, you must create a `Trigger` which listens for your events and places them somewhere. Let's do that next!
