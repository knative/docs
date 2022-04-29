## Using a Knative Service as a source
In this tutorial, you will use the [CloudEvents](https://github.com/ruromero/cloudevents-player) Player app to showcase the core concepts of Knative Eventing. 
By the end of this tutorial, you should have an architecture that looks like this:
![cloud-events-app](assets/cloud-events-app.png)
The above image is Figure 6.6 from [Knative in Action](https://www.manning.com/books/knative-in-action).

### Creating your first source
The CloudEvents Player acts as a Source for CloudEvents by intaking the URL of the Broker as an environment variable, 
`BROKER_URL`. You will send CloudEvents to the Broker through the CloudEvents Player application.

Create the CloudEvents Player Service:
```sh
kn service create cloudevents-player \
--image ruromero/cloudevents-player:latest \
--env BROKER_URL=http://broker-ingress.knative-eventing.svc.cluster.local/default/example-broker
```{{execute}}

✅ **Expected output:**
```sh
Service 'cloudevents-player' created to latest revision 'cloudevents-player-00001' is available at URL:
http://cloudevents-player.default.example.com
```

> ❓ **Why is my Revision named something different!**
> Because we didn't assign a revision-name, Knative Serving automatically created one for us. It's okay if your Revision is named something different.

### Accessing the cloudevents-player service
To be able to access the service we need to create an entry in `/etc/hosts` like this:
```sh
echo "${externalIP} cloudevents-player.default.example.com" >> /etc/hosts
```{{execute}}

And also we need to `port-forward` the requests to the Ingress controller. We do this by running:
```sh
kubectl port-forward -n contour-external service/envoy 8080:80 &
```{{execute}}
This process is going to run in the brackground.

### Sending an event
Try sending an event using the CloudEvents service just deployed:
```sh
curl -i http://cloudevents-player.default.example.com \
    -H "Content-Type: application/json" \
    -H "Ce-Id: 123456789" \
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

❓ **What do these fields mean?**

| Field            | Description     |
| -----------      | -----------     |
| Ce-Id            | A unique ID     |
| Ce-Type          | An event type   |
| Ce-Source        | An event source |
| Ce-Specversion   | Demarcates which CloudEvents spec you are using (should always be 1.0)  |
| msg              | The `data` section of the CloudEvent, a payload which is carrying the data you care to be delivered |

> For more information on the CloudEvents Specification, check out the [CloudEvents Spec](https://github.com/cloudevents/spec/blob/v1.0.1/spec.md).


### Get events
To get the list of Events run this command:
```sh
curl http://cloudevents-player.default.example.com/messages | jq
```{{execute}}

You can now see that the event has been sent to our Broker... but where has the event gone? 
**Well, right now, nowhere!**

A Broker is simply a receptacle for events. In order for your events to be sent anywhere, 
you must create a **Trigger** which listens for your events and places them somewhere. 
And, you're in luck; you'll create your first **Trigger** on the next page!
