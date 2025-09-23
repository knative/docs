# Configure KEDA Autoscaling of Knative Kafka Resources

All of the Knative Kafka components which dispatch events (source, channel broker) support scaling the dispatcher data plane with KEDA.

!!! important
    This feature is Alpha

## Enable Autoscaling of Kafka components

!!! important
    Note that enabling autoscaling will enable scaling for all KafkaSources, Triggers referencing Kafka Brokers, and Subscriptions referencing KafkaChannels

To enable the feature, you need to modify the `config-kafka-features` configmap and set the `controller-autoscaler-keda` flag to `enabled`.
Note that in order for this feature to work, you must also install KEDA into your cluster.

After your changes your configmap should look like:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka-features
  namespace: knative-eventing
data:
  controller-autoscaler-keda: enabled
  # other features and config options...

```

## Configure Autoscaling for a Resource

If you want to customize how KEDA scales a KafkaSource, trigger, or subscription you can set annotations on the resource:

```yaml
apiVersion: <eventing|messaging|sources>.knative.dev/v1
kind: <KafkaSource|Subscription|Trigger>
metadata:
  annotations:
    # The minimum number of replicas to scale down to
    autoscaling.eventing.knative.dev/min-scale: "0"
    # The maximum number of replicas to scale up to
    autoscaling.eventing.knative.dev/max-scale: "50"
    # The interval in seconds the autoscaler uses to poll metrics in order to inform its scaling decisions
    autoscaling.eventing.knative.dev/polling-interval: "10"
    # The period in seconds the autoscaler waits until it scales down
    autoscaling.eventing.knative.dev/cooldown-period: "30"
    # The lag that is used for scaling (1<->N)
    autoscaling.eventing.knative.dev/lag-threshold: "100"
    # The lag that is used for activation (0<->1)
    autoscaling.eventing.knative.dev: "0"
spec:
  # Spec fields for the resource...
```

## Disable Autoscaling for a Resource

If you want to disable autoscaling for a KafkaSource, trigger, or subscription, you need to set an annotation on the resource:

```yaml
apiVersion: <eventing|messaging|sources>.knative.dev/v1
kind: <KafkaSource|Subscription|Trigger>
metadata:
  annotations:
    autoscaling.eventing.knative.dev/class: disabled
spec:
  # Spec fields for the resource...
```
