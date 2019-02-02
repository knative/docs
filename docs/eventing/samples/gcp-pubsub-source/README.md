
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
   that you've set the `$PROJECT_ID` environment variable to your Google Cloud
   project id, and also set your project ID as default using
   `gcloud config set project $PROJECT_ID`.

1. Setup [Knative Serving](../../../../install)

1. Setup
   [Knative Eventing](https://github.com/knative/docs/tree/master/eventing).
   In addition, install the GCP PubSub event source from `release-gcppubsub.yaml`:

      kubectl apply --filename kubectl apply --filename https://github.com/knative/eventing-sources/releases/download/v0.3.0/release-gcppubsub.yaml

1. Enable the 'Cloud Pub/Sub API' on your project:

   ```shell
   gcloud services enable pubsub.googleapis.com
   ```

1. Create a
   [GCP Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts/project).
   This sample creates one service account for both registration and receiving
   messages, but you can also create a separate service account for receiving
   messages if you want additional privilege separation.

   1. Create a new service account named `knative-source` with the following
      command:
      ```shell
      gcloud iam service-accounts create knative-source
      ```
   1. Give that Service Account the 'Pub/Sub Editor' role on your GCP project:
      ```shell
      gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member=serviceAccount:knative-source@$PROJECT_ID.iam.gserviceaccount.com \
        --role roles/pubsub.editor
      ```
   1. Download a new JSON private key for that Service Account. **Be sure not to
      check this key into source control!**
      ```shell
      gcloud iam service-accounts keys create knative-source.json \
        --iam-account=knative-source@$PROJECT_ID.iam.gserviceaccount.com
      ```
   1. Create two secrets on the kubernetes cluster with the downloaded key:

      ```shell
      # Note that the first secret may already have been created when installing
      # Knative Eventing. The following command will overwrite it. If you don't
      # want to overwrite it, then skip this command.
      kubectl -n knative-sources create secret generic gcppubsub-source-key --from-file=key.json=knative-source.json --dry-run -o yaml | kubectl apply --filename -

      # The second secret should not already exist, so just try to create it.
      kubectl -n default create secret generic google-cloud-key --from-file=key.json=knative-source.json
      ```

      `gcppubsub-source-key` and `key.json` are pre-configured values in the
      `controller-manager` StatefulSet which manages your Eventing sources.

      `google-cloud-key` and `key.json` are pre-configured values in
      [`gcp-pubsub-source.yaml`](../gcp-pubsub-source.yaml).

## Deployment

1. Create a Channel. This example creates a Channel called `pubsub-test` which
   uses the in-memory provisioner, with the following definition:

   ```yaml
   apiVersion: eventing.knative.dev/v1alpha1
   kind: Channel
   metadata:
     name: pubsub-test
   spec:
     provisioner:
       apiVersion: eventing.knative.dev/v1alpha1
       kind: ClusterChannelProvisioner
       name: in-memory-channel
   ```

   If you're in the samples directory, you can apply the `channel.yaml` file:

   ```shell
   kubectl apply --filename channel.yaml
   ```

1. Create a GCP PubSub Topic. If you change its name (`testing`), you also need
   to update the `topic` in the
   [`gcp-pubsub-source.yaml`](../gcp-pubsub-source.yaml) file:

   ```shell
   gcloud pubsub topics create testing
   ```

1. Replace the
   [`MY_GCP_PROJECT` placeholder](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
   in [`gcp-pubsub-source.yaml`](../gcp-pubsub-source.yaml) and apply it.

   If you're in the samples directory, you can replace `MY_GCP_PROJECT` and
   apply in one command:

   ```shell
    sed "s/MY_GCP_PROJECT/$PROJECT_ID/g" gcp-pubsub-source.yaml | \
        kubectl apply --filename -
   ```

   If you are replacing `MY_GCP_PROJECT` manually, then make sure you apply the
   resulting YAML:

   ```shell
   kubectl apply --filename gcp-pubsub-source.yaml
   ```

1. Create a function and subscribe it to the `pubsub-test` channel:

   ```shell
   kubectl apply --filename subscriber.yaml
   ```

## Publish

Publish messages to your GCP PubSub Topic:

```shell
gcloud pubsub topics publish testing --message="Hello world"
```

## Verify

We will verify that the published message was sent into the Knative eventing
system by looking at what is downstream of the `GcpPubSubSource`. If you
deployed the [Subscriber](#subscriber), then continue using this section. If
not, then you will need to look downstream yourself.

1. We need to wait for the downstream pods to get started and receive our event,
   wait 60 seconds.

   - You can check the status of the downstream pods with:

     ```shell
     kubectl get pods --selector serving.knative.dev/service=message-dumper
     ```

     You should see at least one.

1. Inspect the logs of the subscriber:

   ```shell
   kubectl logs --selector serving.knative.dev/service=message-dumper -c user-container
   ```

You should see log lines similar to:

```json
{
  "ID": "284375451531353",
  "Data": "SGVsbG8sIHdvcmxk",
  "Attributes": null,
  "PublishTime": "2018-10-31T00:00:00.00Z"
}
```

The log message is a dump of the message sent by `GCP PubSub`. In particular, if
you [base-64 decode](https://www.base64decode.org/) the `Data` field, you should
see the sent message:

```shell
echo "SGVsbG8sIHdvcmxk" | base64 --decode
```

Results in: "Hello world"

For more information about the format of the message, see the
[PubsubMessage documentation](https://cloud.google.com/pubsub/docs/reference/rest/v1/PubsubMessage).
