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

    After you've created your YAML file, named something like `ce-trigger.yaml`, apply it by running the command:
    ```bash
    kubectl apply -f ce-trigger.yaml
    ```

==**Expected Output**==
    ```{ .bash .no-copy }
    trigger.eventing.knative.dev/cloudevents-trigger created
    ```

trigger.eventing.knative.dev/cloudevents-player created
??? question "What CloudEvents is my Trigger listening for?"
    Because we didn't specify a `--filter` in our `kn` command, the Trigger is listening for any CloudEvents coming into the Broker.

    The following example shows how to use Filters.

Now, when we go back to the CloudEvents Player and send an Event, we see that CloudEvents are both sent and received by the CloudEvents Player:

![CloudEvents Player user interface](images/event_received.png){draggable=false}

You may need to refresh the page to see your changes.

??? question "What if I want to filter on CloudEvent attributes?"
    First, delete your existing Trigger:
    ```bash
      kn trigger delete cloudevents-trigger
    ```
    Now let's add a Trigger that listens for a certain CloudEvent Type
    ```bash
      kn trigger create cloudevents-player-filter --sink cloudevents-player  --broker example-broker --filter type=some-type
    ```

    If you send a CloudEvent with type "some-type," it is reflected in the CloudEvents Player UI.  The Trigger ignores any other types.

    You can filter on any aspect of the CloudEvent you would like to.


Some people call this **"Event-Driven Architecture"** which can be used to create your own **"Functions as a Service"** on Kubernetes :tada: :taco: :fire:
