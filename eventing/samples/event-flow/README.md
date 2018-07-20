# Sample: Binding running services to an IoT core (PubSub)

> For the ease of the demo, a few variables here are hard-coded.

## Setup

Define environment variables:

```shell
export IOTCORE_PROJECT="s9-demo"
export IOTCORE_REG="next18-demo"
export IOTCORE_DEVICE="next18-demo-client"
export IOTCORE_REGION="us-central1"
export IOTCORE_TOPIC_DATA="iot-demo"
export IOTCORE_TOPIC_DEVICE="iot-demo-device"
```

## Creating a device registry

Run the following command to create a device registry:

```shell
gcloud iot registries create $IOTCORE_REG \
    --project=$IOTCORE_PROJECT \
    --region=$IOTCORE_REGION \
    --event-notification-config=$IOTCORE_TOPIC_DATA \
    --state-pubsub-topic=$IOTCORE_TOPIC_DEVICE
```

## Creating device certificates

Create certificates to connect the device to the IoT Core gateway:

```shell
openssl genrsa -out rsa_private.pem 2048
openssl rsa -in rsa_private.pem -pubout -out rsa_public.pem
```

## Registering the IoT device

Once created, add the public key to the IoT core registry:

```shell
gcloud iot devices create $IOTCORE_DEVICE \
  --project=$IOTCORE_PROJECT \
  --region=$IOTCORE_REGION \
  --registry=$IOTCORE_REG \
  --public-key path=./rsa_public.pem,type=rs256
```

## Generating Data

To mimic an IoT device sending data to the IoT gateway, run the provided
Node.js client with the following parameters:

```shell
node send-data.js \
    --projectId=$IOTCORE_PROJECT \
    --cloudRegion=$IOTCORE_REGION \
    --registryId=$IOTCORE_REG \
    --deviceId=$IOTCORE_DEVICE \
    --privateKeyFile=./iot_demo_private.pem \
    --algorithm=RS256
```

This "device" will publish one event per second to the IoT Core gateway.
The gateway will automatically publish the received events to the configured
PubSub topic (`iot-demo`).

The following payload is sent by this simulated IoT client:

```shell
{
  source_id: 'next18-demo-client',
  event_id: '41e13421-25aa-4e93-bca8-0ffeb5c040c8',
  event_ts: 1531515192370,
  metric: 9
}
```

The `event_id` value here is a unique UUIDv4 ID, `event_ts` is UNIX Epoch time, and `metric` 
is a random number 1-10.

## Create a function that handles events

Now we want to consume these IoT events, so let's create the function to handle the events:

```shell
kubectl apply -f event-flow/route.yaml
kubectl apply -f event-flow/configuration.yaml
```

## Create an event source

Before we can bind an action to an event source, we have to create an event source
that knows how to wire events into actions for that particular event type.

First let's create a ServiceAccount, so that we can run the local receive adapter
in Pull mode to poll for the events from this topic. 

Then let's create a GCP PubSub as an event source that we can bind to.

```shell
kubectl apply -f event-flow/serviceaccount.yaml
kubectl apply -f event-flow/serviceaccountbinding.yaml
kubectl apply -f event-flow/eventsource.yaml
kubectl apply -f event-flow/eventtype.yaml
```

## Bind IoT events to our function

We have now created a function that we want to consume our IoT events, and we have an event
source that's sending events via GCP PubSub, so let's wire the two together:

```shell
kubectl apply -f event-flow/flow.yaml
```
