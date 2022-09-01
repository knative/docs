# Installing Knative Kafka

## Prerequisites

- You have installed Knative Eventing

## Procedure

1. Install the Kafka controller:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
    ```

1. Verify that `kafka-controller` is running, by entering the following command:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:
    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    kafka-controller               1/1     1            1           3s
    ```

## Enabling Knative Kafka features

Before you can use Knative's Kafka integration, you must enable Kafka features in the `KnativeEventing` custom resource (CRD).

### Enabling Kafka event sources

To enable the Kafka event source feature, you must include the following configuration in the `KnativeEventing` CR:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  source:
    kafka:
      enabled: true
# ...
```

## Advanced Kafka configurations

### Authentication using SASL

Knative supports the following SASL mechanisms:

- `PLAIN`
- `SCRAM-SHA-256`
- `SCRAM-SHA-512`

To use a specific SASL mechanism replace `<sasl_mechanism>` with the mechanism of your choice.

#### Authentication using SASL without encryption

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SASL_PLAINTEXT \
  --from-literal=sasl.mechanism=<sasl_mechanism> \
  --from-literal=user=<my_user> \
  --from-literal=password=<my_password>
```

#### Authentication using SASL and encryption using SSL

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SASL_SSL \
  --from-literal=sasl.mechanism=<sasl_mechanism> \
  --from-file=ca.crt=caroot.pem \
  --from-literal=user=<my_user> \
  --from-literal=password=<my_password>
```

#### Encryption using SSL without client authentication

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SSL \
  --from-file=ca.crt=<my_caroot.pem_file_path> \
  --from-literal=user.skip=true
```

#### Authentication and encryption using SSL

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SSL \
  --from-file=ca.crt=<my_caroot.pem_file_path> \
  --from-file=user.crt=<my_cert.pem_file_path> \
  --from-file=user.key=<my_key.pem_file_path>
```

!!! note
    The `ca.crt` can be omitted to enable fallback and use the system's root CA set.

### Enable debug logging for Kafka data plane components

To enable debug logging for data plane components change the logging level to `DEBUG` in the `kafka-config-logging` ConfigMap.

1. Create the `kafka-config-logging` ConfigMap as a YAML file that contains the following:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: kafka-config-logging
      namespace: knative-eventing
    data:
      config.xml: |
        <configuration>
          <appender name="jsonConsoleAppender" class="ch.qos.logback.core.ConsoleAppender">
            <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
          </appender>
          <root level="DEBUG">
            <appender-ref ref="jsonConsoleAppender"/>
          </root>
        </configuration>
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

2. Restart the `kafka-sink-receiver`:

    ```bash
    kubectl rollout restart deployment -n knative-eventing kafka-sink-receiver
    ```

### Kafka Producer configurations

A Kafka Producer is the component responsible for sending events to the Kafka cluster. You can change the configuration for Kafka Producers in your cluster by modifying the `config-kafka-sink-data-plane` ConfigMap in the `knative-eventing` namespace.

Documentation for the settings available in this ConfigMap is available on the
[Apache Kafka website](https://kafka.apache.org/documentation/),
in particular, [Producer configurations](https://kafka.apache.org/documentation/#producerconfigs).
