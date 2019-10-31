---
title: "GCP Cloud Pub/Sub source"
linkTitle: "Pub/Sub source"
weight: 20
type: "docs"
---

This sample shows how to configure the GCP PubSub event source. This event
source is most useful as a bridge from other GCP services, such as
[Cloud Storage](https://cloud.google.com/storage/docs/pubsub-notifications),
[IoT Core](https://cloud.google.com/iot/docs/how-tos/devices) and
[Cloud Scheduler](https://cloud.google.com/scheduler/docs/creating#).

## Prerequisites

1. Create a
   [Google Cloud project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
   and install the `gcloud` CLI and run `gcloud auth login`. This sample will
   use a mix of `gcloud` and `kubectl` commands. The rest of the sample assumes
   that you've set the `PROJECT_ID` environment variable to your Google Cloud
   project id, and also set your project ID as default using
   `gcloud config set project $PROJECT_ID`.

1. Enable the `Cloud Pub/Sub API` on your project:

   ```shell
   gcloud services enable pubsub.googleapis.com
   ```

1. Setup [Knative Serving](../../../install)

1. Setup [Knative Eventing](../../../eventing)

1. In addition, install the PubSub event source from `cloud-run-events.yaml`:

    1. To install the PubSub source, first install the CRDs by running the `kubectl apply`
       command with the `--selector events.cloud.google.com/crd-install=true` flag. This prevents
       race conditions during the install, which cause intermittent errors:

        ```shell
        kubectl apply --selector events.cloud.google.com/crd-install=true \
        --filename https://github.com/google/knative-gcp/releases/download/{{< version >}}/cloud-run-events.yaml
        ```

    1. To complete the install of the PubSub source and its dependencies, run the
       `kubectl apply` command again, this time without the `--selector` flag:

        ```shell
        kubectl apply --filename https://github.com/google/knative-gcp/releases/download/{{< version >}}/cloud-run-events.yaml
        ```

1.  Create a
    [Google Cloud Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts/project).
    This sample creates one Service Account for both registration and receiving
    messages, but you can also create a separate Service Account for receiving
    messages if you want additional privilege separation.

    1.  Create a new Service Account named `gcp-source` with the following command:

        ```shell
        gcloud iam service-accounts create gcp-source
        ```

    1.  Give that Service Account the `Pub/Sub Editor` role on your Google Cloud
        project:

        ```shell
        gcloud projects add-iam-policy-binding $PROJECT_ID \
          --member=serviceAccount:gcp-source@$PROJECT_ID.iam.gserviceaccount.com \
          --role roles/pubsub.editor
        ```

    1.  Download a new JSON private key for that Service Account. **Be sure not
        to check this key into source control!**

        ```shell
        gcloud iam service-accounts keys create gcp-source.json \
        --iam-account=gcp-source@$PROJECT_ID.iam.gserviceaccount.com
        ```

    1.  Create a Secret on the Kubernetes cluster with the downloaded key:

        ```shell
        # The Secret should not already exist, so just try to create it.
        kubectl --namespace default create secret generic google-cloud-key --from-file=key.json=gcp-source.json
        ```

        `google-cloud-key` and `key.json` are default values expected by the PubSub source.

## Deployment

1. Create the `default` Broker in your namespace. These instructions assume the
   namespace `default`, feel free to change to any other namespace you would
   like to use instead:

   ```shell
   kubectl label namespace default knative-eventing-injection=enabled
   ```

1. Create a GCP PubSub Topic. If you change its name (`testing`), you also need
   to update the `topic` in the
   [`gcp-pubsub-source.yaml`](./gcp-pubsub-source.yaml) file:

   ```shell
   gcloud pubsub topics create testing
   ```

1. If you are *not* running on GKE, uncomment the project line in [`gcp-pubsub-source.yaml`](./gcp-pubsub-source.yaml) 
   and replace `MY_GCP_PROJECT` with your `PROJECT_ID`. If you are running on GKE, we use GKE's metadata server to
   automatically set the project information. Make sure to apply the yaml:

   ```shell
   kubectl apply --filename gcp-pubsub-source.yaml
   ```

1. Create a function that will receive the event:

   ```shell
   kubectl apply --filename event-display.yaml
   ```

1. Create a Trigger that will send all events from the
   Broker to the function:

   ```shell
   kubectl apply --filename trigger.yaml
   ```

## Publish

Publish messages to your GCP PubSub topic:

```shell
gcloud pubsub topics publish testing --message='{"Hello": "world"}'
```

## Verify

We will verify that the published message was sent into the Knative eventing
mesh by looking at the logs of the function subscribed, through a Trigger,
to the `default` Broker.

1. We need to wait for the downstream pods to get started and receive our event,
   wait a few seconds.

   - You can check the status of the downstream pods with:

     ```shell
     kubectl get pods --selector serving.knative.dev/service=event-display
     ```

     You should see at least one.

1. Inspect the logs of the subscriber:

   ```shell
   kubectl logs --selector serving.knative.dev/service=event-display -c user-container
   ```

You should see log lines similar to:

```shell
☁️  CloudEvent: valid ✅
Context Attributes,
  SpecVersion: 0.3
  Type: com.google.cloud.pubsub.topic.publish
  Source: //pubsub.googleapis.com/projects/PROJECT_ID/topics/testing
  ID: 815117146007971
  Time: 2019-10-31T04:49:12.582Z
  DataContentType: application/json
  Extensions:
    knativecemode: binary
    knativearrivaltime: 2019-10-31T04:49:12Z
    knativehistory: default-kne-trigger-kn-channel.default.svc.cluster.local
    traceparent: 00-c9659e66c0ed05d6f4fac3e57e62287c-05a289c3e928e698-00
Transport Context,
  URI: /
  Host: event-display.default.svc.cluster.local
  Method: POST
Data,
  {
    "Hello": "world"
  }
```

For more information about the format of the `Data,` see
the `data` field of
[PubsubMessage documentation](https://cloud.google.com/pubsub/docs/reference/rest/v1/PubsubMessage).

For more information about CloudEvents, see the
[HTTP transport bindings documentation](https://github.com/cloudevents/spec).
