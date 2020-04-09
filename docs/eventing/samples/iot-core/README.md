This sample shows how to bind a running service to an
[IoT core](https://cloud.google.com/iot-core/) using
[GCP PubSub](https://cloud.google.com/pubsub/) as the event source. With minor
modifications, it can be used to bind a running service to anything that sends
events via GCP PubSub.

```
Note: All commands are given relative to the root of this repository.
```

## Deployment Steps

### Environment Variables

To make the following commands easier, we are going to set the various variables
here and use them later.

#### Variables you must Change

```shell
export IOTCORE_PROJECT="s9-demo"
```

#### Variables you may Change

```shell
export IOTCORE_REGISTRY="iot-demo"
export IOTCORE_DEVICE="iot-demo-client"
export IOTCORE_REGION="us-central1"
export IOTCORE_TOPIC_DATA="iot-demo-pubsub-topic"
export IOTCORE_TOPIC_DEVICE="iot-demo-device-pubsub-topic"
```

### Prerequisites

#### Kubernetes

1.  Have a running Kubernetes cluster with `kubectl` pointing at it.

#### GCP

1.  Create a
    [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

1.  Have [gcloud](https://cloud.google.com/sdk/gcloud/) installed and pointing
    at that project.

1.  Enable the `Cloud Pub/Sub API` on that project.

    ```shell
    gcloud services enable pubsub.googleapis.com
    ```

1.  Create the two GCP PubSub `topic`s.

    ```shell
    gcloud pubsub topics create $IOTCORE_TOPIC_DATA
    gcloud pubsub topics create $IOTCORE_TOPIC_DEVICE
    ```

1.  Setup [Knative Eventing](../../../eventing).

#### GCP PubSub Source

1.  Create a GCP
    [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts/project).

    1.  Determine the Service Account to use, or create a new one.
    1.  Give that Service Account the 'Pub/Sub Editor' role on your GCP project.
    1.  Download a new JSON private key for that Service Account.
    1.  Create two secrets with the downloaded key (one for the Source, one for
        the Receive Adapter):

        ```shell
        kubectl --namespace knative-sources create secret generic gcppubsub-source-key --from-file=key.json=PATH_TO_KEY_FILE.json
        kubectl --namespace default create secret generic google-cloud-key --from-file=key.json=PATH_TO_KEY_FILE.json
        ```

1.  Deploy the `GcpPubSubSource` controller as part of eventing-source's
    controller.

    ```shell
    kubectl apply --filename https://github.com/knative/eventing-contrib/releases/download/v0.8.2/gcppubsub.yaml
    ```

### Deploying

#### Broker

1. Install the default `Broker`.

   ```shell
   kubectl label namespace default knative-eventing-injection=enabled
   ```

#### GCP PubSub Source

1.  Deploy `gcp-pubsub-source.yaml`.

    ```shell
    sed -e "s/PROJECT_ID/$IOTCORE_PROJECT/" \
        -e "s/TOPIC_NAME/$IOTCORE_TOPIC_DATA/" \
        docs/eventing/samples/iot-core/gcp-pubsub-source.yaml |
    kubectl apply --filename -
    ```

#### Trigger

Even though the `Source` isn't completely ready yet, we can setup the `Trigger`
for all events coming out of it.

1.  Deploy `trigger.yaml`.

    ```shell
    kubectl apply --filename docs/eventing/samples/iot-core/trigger.yaml
    ```

    - This uses a very simple Knative Service to see that events are flowing.
      Feel free to replace it.

#### IoT Core

We now have everything setup on the Knative side. We will now setup the IoT
Core.

1.  Create a device registry:

    ```shell
    gcloud iot registries create $IOTCORE_REGISTRY \
        --project=$IOTCORE_PROJECT \
        --region=$IOTCORE_REGION \
        --event-notification-config=topic=$IOTCORE_TOPIC_DATA \
        --state-pubsub-topic=$IOTCORE_TOPIC_DEVICE
    ```

1.  Create the certificates.

    ```shell
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout device.key.pem \
        -out device.crt.pem \
        -days 365 \
        -subj "/CN=unused"
    curl https://pki.google.com/roots.pem > ./root-ca.pem
    ```

1.  Register a device using the generated certificates.

    ```shell
    gcloud iot devices create $IOTCORE_DEVICE \
      --project=$IOTCORE_PROJECT \
      --region=$IOTCORE_REGION \
      --registry=$IOTCORE_REGISTRY \
      --public-key path=./device.crt.pem,type=rsa-x509-pem
    ```

### Running

We now have everything installed and ready to go. We will generate events and
see them in the subscriber.

1.  Run the following program to generate events:

    ```shell
    go run github.com/knative/docs/docs/eventing/samples/iot-core/generator \
        -project $IOTCORE_PROJECT \
        -region $IOTCORE_REGION \
        -registry $IOTCORE_REGISTRY \
        -device $IOTCORE_DEVICE \
        -ca "$PWD/root-ca.pem" \
        -key "$PWD/device.key.pem" \
        -src "iot-core demo" \
        -events 10
    ```

1.  Inspect the logs of the subscriber:

    ```shell
    kubectl logs --selector serving.knative.dev/service=event-display -c user-container
    ```

    You should see something along the similar to:

    ```shell
    {"ID":"481014114648052","Data":"eyJzb3VyY2VfaWQiOiJpb3QtY29yZSBkZW1vIiwiZXZlbnRfaWQiOiJlaWQtMzI3MjJiMzItZWU5Mi00YzZlLWEzOTgtNDlmYjRkYWYyNGE1IiwiZXZlbnRfdHMiOjE1NTM3MTczOTYsIm1ldHJpYyI6MC4xMzY1MjI5OH0=","Attributes":{"deviceId":"iot-demo-client","deviceNumId":"2754785852315736","deviceRegistryId":"iot-demo","deviceRegistryLocation":"us-central1","projectId":"s9-demo","subFolder":""},"PublishTime":"2019-03-27T20:09:56.685Z"}
    ```

### Cleanup

To cleanup the knative resources:

1.  Remove the `GcpPubSubSource`:

    ```shell
    sed -e "s/PROJECT_ID/$IOTCORE_PROJECT/" \
        -e "s/TOPIC_NAME/$IOTCORE_TOPIC_DATA/" \
        docs/eventing/samples/iot-core/gcp-pubsub-source.yaml |
    kubectl delete --filename -
    ```

1.  Remove the Trigger:

    ```shell
    kubectl delete --filename docs/eventing/samples/iot-core/trigger.yaml
    ```

1.  Remove the `GcpPubSubSource` controller:

    ```shell
    kubectl delete --filename https://github.com/knative/eventing-contrib/releases/download/v0.8.2/gcppubsub.yaml
    ```
