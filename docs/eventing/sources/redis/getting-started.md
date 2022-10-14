# Creating a RedisStreamSource

![version](https://img.shields.io/badge/API_Version-v1alpha1-red?style=flat-square)

This topic describes how to create a `RedisStreamSource` object.

## Install the RedisStreamSource add-on

`RedisStreamSource` is a Knative Eventing add-on.

1. Install RedisStreamSource by running the command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-redis", file="redis-source.yaml") }}
    ```

1. Verify that `redis-controller-manager`is running:

    ```bash
    kubectl get deployments.apps -n knative-sources
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    redis-controller-manager        1/1     1            1           3s
    ```

{% include "event-display.md" %}

## Create a RedisStreamSource object

1. Create the `RedisStreamSource` object using the YAML template below:

  ```yaml
  apiVersion: sources.knative.dev/v1alpha1
  kind: RedisStreamSource
  metadata:
    name: <redis-stream-source>
  spec:
    address: <redis-uri>
    stream: <redis-stream-name>
    group: <consumer-group-name>
    sink: <sink>
  ```

Where:

* `<redis-stream-source>` is the name of your source. (required)
* `<redis-uri>` is the Redis URI. See the [Redis documentation](https://redis.io/docs/manual/cli/#host-port-password-and-database) for more information. (required)
* `<redis-stream-name>` is the name of the Redis stream. (required)
* `<consumer-group-name>` is the name of the Redis consumer group. When left empty a group
   is automatically created for this source, and deleted when this source is deleted. (optional)
* `<sink>` is where to send events. (required)

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>
    ```

    Where `<filename>` is the name of the file you created in the previous step.

## Verify the RedisStreamSource object

1. View the logs for the `event-display` event consumer by running the command:

    ```bash
    kubectl logs -l app=event-display --tail=100
    ```

    Sample output:

    ```{ .bash .no-copy }
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: dev.knative.sources.redisstream
      source: /mystream
      id: 1597775814718-0
      time: 2020-08-18T18:36:54.719802342Z
      datacontenttype: application/json
    Data,
      [
        "fruit",
        "banana"
        "color",
        "yellow"
      ]
    ```

## Delete the RedisStreamSource object

* Delete the `RedisStreamSource` object:

    ```bash
    kubectl delete -f <filename>
    ```

## Additional information

* For more information about Redis Stream source, see the [`eventing-redis` Github repository](https://github.com/knative-sandbox/eventing-redis/tree/main/config/source)
