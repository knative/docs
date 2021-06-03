## Creating your first `Trigger`
=== "kn"

    ```bash
    kn trigger create cloudevents-player --sink cloudevents-player
    ```

=== "YAML"
    ```bash
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: cloudevents-player
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
==**Expected Output**==
```{ .bash .no-copy }
Trigger 'cloudevents-player' successfully created in namespace 'default'.
```

??? question "What CloudEvents is my `Trigger` listening for?"
    Since we didn't specify a `--filter` in our `kn` command, our Trigger is listening for any CloudEvents coming into the `Broker`.

Now, when we go back to the CloudEvents Player and send an Event, we see that CloudEvents are both sent and received by the CloudEvents Player:

<figure>
  <img src="https://user-images.githubusercontent.com/16281246/116411017-4f13d480-a803-11eb-9982-cd9012781fe6.png" draggable="false">
  <figcaption>You may need to refresh the page to see your changes</figcaption>
</figure>



??? question "What if I want to filter on CloudEvent attributes?"
    First, delete your existing Trigger:
    ```bash
      kn trigger delete cloudevents-player
    ```
    Now let's add a Trigger that listens for a certain CloudEvent Type
    ```bash
      kn trigger create cloudevents-player --sink cloudevents-player --filter type=some-type
    ```

    If you send a CloudEvent with type "some-type," it will be reflected in the CloudEvents Player UI. Any other types will be ignored by the `Trigger`.

    You can filter on any aspect of the CloudEvent you would like to.


Some people call this **"Event-Driven Architecture"** which can be used to create your own **"Functions as a Service"** on Kubernetes :tada: :taco: :fire:
