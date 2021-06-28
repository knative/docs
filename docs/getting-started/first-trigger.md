## Creating your first Trigger
=== "kn"

    ```bash
    kn trigger create cloudevents-trigger --sink cloudevents-player  --broker example-broker
    ```

    ```{ .bash .no-copy }
    Trigger 'cloudevents-trigger' successfully created in namespace 'default'.
    ```
=== "YAML"
    ```bash
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: cloudevents-trigger
      annotations:
        knative-eventing-injection: enabled
    spec:
      broker: example-broker
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: cloudevents-player
    ```

    Once you've created your YAML file (named something like "ce-trigger.yaml"):
    ``` bash
    kubectl apply -f ce-trigger.yaml
    ```

    ==**Expected Output**==
    ```{ .bash .no-copy }
    trigger.eventing.knative.dev/cloudevents-trigger created
    ```


trigger.eventing.knative.dev/cloudevents-player created
??? question "What CloudEvents is my Trigger listening for?"
    Since we didn't specify a `--filter` in our `kn` command, our Trigger is listening for any CloudEvents coming into the Broker.

    An example on how to use Filters is provided below. 

Now, when we go back to the CloudEvents Player and send an Event, we see that CloudEvents are both sent and received by the CloudEvents Player:

<figure>
  <img src="../images/event_received.png" draggable="false">
  <figcaption>You may need to refresh the page to see your changes</figcaption>
</figure>



??? question "What if I want to filter on CloudEvent attributes?"
    First, delete your existing Trigger:
    ```bash
      kn trigger delete cloudevents-player
    ```
    Now let's add a Trigger that listens for a certain CloudEvent Type
    ```bash
      kn trigger create cloudevents-player-filter --sink cloudevents-player  --broker example-broker --filter type=some-type
    ```

    If you send a CloudEvent with type "some-type," it will be reflected in the CloudEvents Player UI. Any other types will be ignored by the Trigger.

    You can filter on any aspect of the CloudEvent you would like to.


Some people call this **"Event-Driven Architecture"** which can be used to create your own **"Functions as a Service"** on Kubernetes :tada: :taco: :fire:
