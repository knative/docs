## Creating your first `Trigger`
Earlier you read that Triggers ":material-magnet-on: act as a filter for events entering the broker and can be configured with desired event attributes," now you'll get to see one in action!

=== "kn"

    ```bash
    kn trigger create cloudevents-player --sink cloudevents-player
    ```

=== "YAML"

    //TODO

==**Expected Output**==
```{ .bash .no-copy }
Trigger 'cloudevents-player' successfully created in namespace 'default'.
```

Notice that we specified a `--sink` (:material-download: A destination for events) and passed in the name of our Knative Service. Now, CloudEvents which enter the broker will be sent to the `cloudevents-player` Service.

??? question "Weren't `Triggers` supposed to filter CloudEvents?"
    Since we didn't specify a `--filter` in our `kn` command, our Trigger is listening for any CloudEvents coming into the `Broker`, regardless of their shape.


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


You've just created an example of **"Event-Driven Architecture"** which can be used to create your own **"Functions as a Service"** on Kubernetes :tada: :taco: :fire:
