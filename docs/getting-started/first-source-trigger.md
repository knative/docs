## Creating your first Source
Now that we have a `Broker`, let's send some CloudEvents to using a `Source`.

A `Source` is Kubernetes customer resource (CR) that emits CloudEvents to a specified location (in our case, a `Broker`). Basically, a `Source` is exactly what it sounds like: it's a "source" of CloudEvents.

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
![Screen Shot 2021-04-13 at 9 34 24 PM](https://user-images.githubusercontent.com/16281246/114641562-5504a400-9ca0-11eb-944a-13a2251b3488.png)

The :material-send: icon in the "Status" column implies that the event has been sent to our `Broker` which we specified through the environment variable `BROKER_URL`. But where has the event gone? Well, right now, nowhere!

A `Broker` is simply a receptacle for events. In order for our events to be sent somewhere, we must create a `Trigger` which listens for our events.
