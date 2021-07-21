## Use Case
The broker and trigger model is useful for complex event delivery topologies like N:M:Z, i.e. there are a multitude of Sources sending events, Functions
consuming/transforming which are then processed by even more functions and so on. It can get a bit unwieldy to keep track of which Channel is having which events. Also, sometimes you might only want to
consume specific types of events. You would have to receive all the events, and throw out the ones you’re not interested in. To make these kinds of interactions easier and allow the
user to only focus on declaring which events they are interested in and where to send them is an easier way to reason about them. This is where Broker and Trigger are meant
to provide a straightforward user experience.

### Broker
Producers POST events to the Broker. Once an Event has entered the Broker, it can be forwarded to event Channels by using Triggers. This event delivery mechanism hides
details of event routing from the event producer and event consumer.

### Trigger
A Trigger describes a filter on event attributes which should be delivered to Consumers. This allows the consumer to only receive a subset of the events.

### Example
Suppose we want to implement the following workflow for events
![broker-eg](assets/broker-eg.png)

We can implement this with Channel and Subscription, but in order for that we’d need 6 Channels and have two instances of Consumer1 (because we would need to have it output
to two different channels to separate Red and Yellow without Consumer2 and Consumer4 having to filter out the events they didn’t want). We would furthermore need to have 6
Subscription objects. By using the Broker / Trigger we only have to declare that Consumer1 is interested in Blue and Orange events, Consumer2 is interested in Red events and so forth. The new topology now becomes:
![broker](assets/broker.png)

To see this in action let us first create a Broker:

```
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
EOF
```{{execute}}

Now we will create consumers that will simply log the event. (We will only create two consumers, the rest will be very similar):

```
for i in 1 2; do
cat <<EOF | kubectl create -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: consumer${i}
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
EOF
done
```{{execute}}

Let us now create Triggers that will send only the events that the consumer is interested in:

For `consumer2`, we create a filter for Red events only

```
kubectl apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: consumer2-red
spec:
  broker: default
  filter:
    attributes:
      type: red
  subscriber:
    ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: consumer2
EOF
```{{execute}}

For `consumer1` we will create 2 triggers, one for blue and one for orange events.

```
kubectl apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: consumer1-blue
spec:
  broker: default
  filter:
    attributes:
      type: blue
  subscriber:
    ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: consumer1
---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: consumer1-orange
spec:
  broker: default
  filter:
    attributes:
      type: orange
  subscriber:
    ref:
     apiVersion: serving.knative.dev/v1
     kind: Service
     name: consumer1
EOF
```{{execute}}
