In this tutorial, you use the [CloudEvents Player](https://github.com/ruromero/cloudevents-player){target=blank} to showcase the core concepts of Knative Eventing. By the end of this tutorial, you should have an architecture that looks like this:

<figure>
  <img src="../images/event_diagram.png" draggable="false">
  <figcaption>Figure 6.6 from <a href = "https://www.manning.com/books/knative-in-action" target="_blank">Knative in Action</a> <br>
Here, the CloudEvents Player is acting as both a <code>Source</code> and a <code>Sink</code> for CloudEvents.
  </figcaption>
</figure>

## Creating your first Source
The CloudEvents Player acts as a Source for CloudEvents by intaking the URL of the Broker as an environment variable, `BROKER_URL`. You will send CloudEvents to the Broker through the CloudEvents Player application.

Create the CloudEvents Player Service:
=== "kn"

    ```bash
    kn service create cloudevents-player \
    --image ruromero/cloudevents-player:latest \
    --env BROKER_URL=http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker
    ```
    ==**Expected Output**==
    ```{ .bash .no-copy }
    Service 'cloudevents-player' created to latest revision 'cloudevents-player-vwybw-1' is available at URL:
    http://cloudevents-player.default.127.0.0.1.nip.io
    ```

    ??? question "Why is my Revision named something different!"
        Because we didn't assign a `revision-name`, Knative Serving automatically created one for us. It's okay if your Revision is named something different.

=== "YAML"

    ```bash
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: cloudevents-player
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/minScale: "1"
        spec:
          containers:
            - image: ruromero/cloudevents-player:latest
              env:
                - name: BROKER_URL
                  value: http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker
    ```

    Once you've created your YAML file, named something like `cloudevents-player.yaml`, apply it by running the command:
    ``` bash
    kubectl apply -f cloudevents-player.yaml
    ```

    ==**Expected Output**==
    ```{ .bash .no-copy }
    service.serving.knative.dev/cloudevents-player created
    ```

## Examining the CloudEvents Player
**You can use the CloudEvents Player to send and receive CloudEvents.** If you open the [Service URL](http://cloudevents-player.default.127.0.0.1.nip.io){target=_blank} in your browser, the **Create Event** form appears.

<figure>
  <img src="../images/event_form.png" draggable="false">
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

  1. Fill in the form with whatever you data you want.
  1. Ensure your Event Source does not contain any spaces.
  1. Click **SEND EVENT**.

![CloudEvents Player Send](images/event_sent.png)


??? tip "Clicking the :fontawesome-solid-envelope: shows you the CloudEvent as the Broker sees it."
    ![Event_Details](images/event_details.png)

The :material-send: icon in the "Status" column implies that the event has been sent to our Broker... but where has the event gone? **Well, right now, nowhere!**

A Broker is simply a receptacle for events. In order for your events to be sent anywhere, you must create a Trigger which listens for your events and places them somewhere. And, you're in luck: you'll create your first Trigger on the next page!
