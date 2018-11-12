# GCP Cloud Pub/Sub - Source

## Deployment Steps

### Prerequisites

1. Create a [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
1. Enable the 'Cloud Pub/Sub API' on that project.

    ```shell
    gcloud services enable pubsub.googleapis.com
    ```

1. Setup [Knative Eventing](https://github.com/knative/docs/tree/master/eventing).
1. Install the [in-memory `ClusterChannelProvisioner`](https://github.com/knative/eventing/tree/master/config/provisioners/in-memory-channel).
    - Note that you can skip this if you choose to use a different type of `Channel`. If so, you will need to modify `channel.yaml` before deploying it.
1. Create a `Channel`. You can use your own `Channel` or use the provided sample, which creates `qux-1`. If you use your own `Channel` with a different name, then you will need to alter other commands later.

    ```shell
    kubectl -n default apply -f eventing/samples/gcp-pubsub-source/channel.yaml
    ```

1. Create GCP [Service Account(s)](https://console.cloud.google.com/iam-admin/serviceaccounts/project). You can either create one with both permissions or two different ones for least privilege. If you create only one, then use the permissions for the `Source`'s Service Account (which is a superset of the Receive Adapter's permission) and provide the same key in both secrets.
    - The `Source`'s Service Account.
        1. Determine the Service Account to use, or create a new one.
        1. Give that Service Account the 'Pub/Sub Editor' role on your GCP project.
        1. Download a new JSON private key for that Service Account.
        1. Create a secret for the downloaded key:

            ```shell
            kubectl -n knative-sources create secret generic gcppubsub-source-key --from-file=key.json=PATH_TO_KEY_FILE.json
            ```

            - Note that you can change the secret's name and the secret's key, but will need to modify `default-gcppubsub.yaml` in a later step with the updated values (they are environment variables on the `StatefulSet`).
    - The Receive Adapter's Service Account.
        1. Determine the Service Account to use, or create a new one.
        1. Give that Service Account the 'Pub/Sub Subscriber' role on your GCP project.
        1. Download a new JSON private key for that Service Account.
        1. Create a secret for the downloaded key in the namespace that the `Source` will be created in:

            ```shell
            kubectl -n default create secret generic google-cloud-key --from-file=key.json=PATH_TO_KEY_FILE.json
            ```

            - Note that you can change the secret's name and the secret's key, but will need to modify `gcp-pubsub-source.yaml`'s `spec.gcpCredsSecret` in a later step with the updated values.
1. Create a GCP PubSub Topic. Replace `TOPIC-NAME` with your desired topic name.

    ```shell
    gcloud pubsub topics create TOPIC-NAME
    ```

### Deployment

1. Deploy the `GcpPubSubSource` controller as part of eventing-source's controller.

    ```shell
    kubectl apply -f https://knative-releases.storage.googleapis.com/eventing-sources/latest/release-with-gcppubsub.yaml
    ```

    - Note that if the `Source` Service Account secret is in a non-default location, you will need to update the YAML first.

1. Replace the place holders in `gcp-pubsub-source.yaml`.
    - `MY_GCP_PROJECT` should be replaced with your [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)'s ID.
    - `TOPIC_NAME` should be replaced with your GCP PubSub Topic's name. It should be the unique portion within the project. E.g. `laconia`, not `projects/my-gcp-project/topics/laconia`.
    - `qux-1` should be replaced with the name of the `Channel` you want messages sent to. If you deployed an unaltered `channel.yaml`, then you can leave it as `qux-1`.
    - `gcpCredsSecret` should be replaced if you are using a non-default secret or key name for the receive adapter's credentials.

1. Deploy `gcp-pubsub-source.yaml`.

    ```shell
    kubectl -n default apply -f eventing/samples/gcp-pubsub-source/gcp-pubsub-source.yaml
    ```

### Subscriber

In order to check the `GcpPubSubSource` is fully working, we will create a simple Knative Service that dumps incoming messages to its log and create a `Subscription` from the `Channel` to that Knative Service.

1. Setup [Knative Serving](https://github.com/knative/docs/tree/master/serving).
1. If the deployed `GcpPubSubSource` is pointing at a `Channel` other than `qux-1`, modify `subscriber.yaml` by replacing `qux-1` with that `Channel`'s name.
1. Deploy `subscriber.yaml`.

    ```shell
    ko apply -f eventing/samples/gcp-pubsub-source/subscriber.yaml
    ```

### Publish

Publish messages to your GCP PubSub Topic.

```shell
gcloud pubsub topics publish TOPIC-NAME --message="Hello World!"
```

### Verify

We will verify that the published message was sent into the Knative eventing system by looking at what is downstream of the `GcpPubSubSource`. If you deployed the [Subscriber](#subscriber), then continue using this section. If not, then you will need to look downstream yourself.

1. Use [`kail`](https://github.com/boz/kail) to tail the logs of the subscriber.

    ```shell
    kail -d message-dumper -c user-container --since=10m
    ```

You should see log lines similar to:

```
{"ID":"284375451531353","Data":"SGVsbG8gV29ybGQh","Attributes":null,"PublishTime":"2018-10-31T00:00:00.00Z"}

```
