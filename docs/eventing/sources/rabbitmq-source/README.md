# Creating a RabbitMQ Source

This topic describes how to create a RabbitMQ Source.

## Prerequisites

To use the RabbitMQ Source, you must have the following installed:

1. [Knative Eventing](../../../install/yaml-install/eventing/install-eventing-with-yaml.md)
1. [RabbitMQ Cluster Operator (optional)](https://github.com/rabbitmq/cluster-operator) - our recommendation is [latest release](https://github.com/rabbitmq/cluster-operator/releases/latest)
1. [CertManager v1.5.4](https://github.com/jetstack/cert-manager/releases/tag/v1.5.4) - easiest integration with RabbitMQ Messaging Topology Operator
1. [RabbitMQ Messaging Topology Operator](https://github.com/rabbitmq/messaging-topology-operator) - our recommendation is [latest release](https://github.com/rabbitmq/messaging-topology-operator/releases/latest) with CertManager

## Install the RabbitMQ controller

1. Install the RabbitMQ Source controller by running the command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-rabbitmq", file="rabbitmq-source.yaml") }}
    ```

1. Verify that `rabbitmq-controller-manager` and `rabbitmq-webhook` are running:

    ```bash
    kubectl get deployments.apps -n knative-sources
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    rabbitmq-controller-manager     1/1     1            1           3s
    rabbitmq-webhook                1/1     1            1           4s
    ```

## Create a RabbitMQ cluster (optional)

1. Deploy a RabbitMQ cluster:

    1. Create a YAML file using the following template:

        ```yaml
        apiVersion: rabbitmq.com/v1beta1
        kind: RabbitmqCluster
        metadata:
          name: <cluster-name>
          annotations:
            # A single RabbitMQ cluster per Knative Eventing installation
            rabbitmq.com/topology-allowed-namespaces: "*"
        ```
        Where `<cluster-name>` is the name you want for your RabbitMQ cluster,
        for example, `rabbitmq`.

    1. Apply the YAML file by running the command:

        ```bash
        kubectl create -f <filename>
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Wait for the cluster to become ready. When the cluster is ready, `ALLREPLICASREADY`
will be `true` in the output of the following command:

    ```bash
    kubectl get rmq <cluster-name>
    ```
    Where `<cluster-name>` is the name you gave your cluster in the step above.

    Example output:

    ```{ .bash .no-copy }
    NAME          ALLREPLICASREADY   RECONCILESUCCESS   AGE
    rabbitmq      True               True               38s
    ```

For more information about configuring the `RabbitmqCluster` CRD, see the
[RabbitMQ website](https://www.rabbitmq.com/kubernetes/operator/using-operator.html).

## Reference an external RabbitMQ Cluster

1. Create a Secret that stores the external RabbitMQ Cluster Credentials and URI:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: rabbitmq-secret-credentials
    # This is just a sample, don't use it this way in production
    stringData:
      username: $EXTERNAL_RABBITMQ_USERNAME
      password: $EXTERNAL_RABBITMQ_PASSWORD
      uri: $EXTERNAL_RABBITMQ_MANAGEMENT_UI_URI:$PORT
    ```

You will reference this Secret in the RabbitMQ Source object later.

## Create a Service

1. Create the `event-display` Service as a YAML file:

     ```yaml
     apiVersion: serving.knative.dev/v1
     kind: Service
     metadata:
       name: event-display
       namespace: default
     spec:
       template:
         spec:
           containers:
             - # This corresponds to
               # https://github.com/knative/eventing/tree/main/cmd/event_display/main.go
               image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
     ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

    Example output:
    ```{ .bash .no-copy }
    service.serving.knative.dev/event-display created
    ```

1. Ensure that the Service Pod is running, by running the command:

    ```bash
    kubectl get pods
    ```

    The Pod name is prefixed with `event-display`:
    ```{ .bash .no-copy }
    NAME                                            READY     STATUS    RESTARTS   AGE
    event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
    ```

## Create a RabbitMQ Source object

1. Create a YAML file using the following template:

    ```yaml
    apiVersion: sources.knative.dev/v1alpha1
    kind: RabbitmqSource
    metadata:
      name: <source-name>
    spec:
      rabbitmqClusterReference:
        # Configure name if a local cluster is being used.
        name: <cluster-name>
        # Configure connectionSecret if an external RabbitMQ cluster is being used.
        connectionSecret:
          name: rabbitmq-secret-credentials
      rabbitmqResourcesConfig:
        parallelism: 10
        exchangeName: "eventing-rabbitmq-source"
        queueName: "eventing-rabbitmq-source"
      delivery:
        retry: 5
        backoffPolicy: "linear"
        backoffDelay: "PT1S"
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display
    ```
    Where:

    - `<source-name>` is the name you want for your RabbitMQ Source object.
    - `<cluster-name>` is the name of the RabbitMQ cluster you created earlier.

    !!! note
        You cannot set `name` and `connectionSecret` at the same time.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>
    ```
    Where `<filename>` is the name of the file you created in the previous step.

### Verify

Check the event-display service to see if it is receiving events.
It might take a while for the Source to start sending events to the Sink.

```sh
  kubectl -l='serving.knative.dev/service=event-display' logs -c user-container
  ☁️  cloudevents.Event
  Context Attributes,
    specversion: 1.0
    type: dev.knative.rabbitmq.event
    source: /apis/v1/namespaces/default/rabbitmqsources/<source-name>
    subject: f147099d-c64d-41f7-b8eb-a2e53b228349
    id: f147099d-c64d-41f7-b8eb-a2e53b228349
    time: 2021-12-16T20:11:39.052276498Z
    datacontenttype: application/json
  Data,
    {
      ...
      Random Data
      ...
    }
```

Congratulations! Your new RabbitMQ Source is working!

### Cleanup

```sh
kubectl delete -f <source-yaml-filename> <service-yaml-filename> <secret-yaml-filename> <cluster-yaml-filename>
```

## Additional information

To report a bug or request a feature, open an issue in the [eventing-rabbitmq repository](https://github.com/knative-sandbox/eventing-rabbitmq).
