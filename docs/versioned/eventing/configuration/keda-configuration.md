---
audience: administrator
components:
  - eventing
function: how-to
---

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

## Configure KEDA scaling globally

To configure the KEDA scaling behaviour globally for all resources you can edit the configmap `config-kafka-autoscaler` in the `knative-eventing` namespace.

Note that the `min-scale` and `max-scale` parameters both refer to the number of Kafka consumers, not the number of dispatcher pods. The number of dispatcher pods in the StatefulSet is determined by `scale / POD_CAPACITY`, where `POD_CAPACITY` is an environment variable you can configure on the `kafka-controller` deployment, and defaults to `20`.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka-autoscaler
  namespace: knative-eventing
data:
  # What autoscaling class should be used. Can either be keda.autoscaling.knative.dev or dispabled.
  class: keda.autoscaling.knative.dev
  # The period in seconds the autoscaler waits until it scales down
  cooldown-period: "30"
  # The lag that is used for scaling (1<->N)
  lag-threshold: "100"
  # The maximum number of replicas to scale up to
  max-scale: "50"
  # The minimum number of replicas to scale down to
  min-scale: "0"
  # The interval in seconds the autoscaler uses to poll metrics in order to inform its scaling decisions
  polling-interval: "10"
```

## Understanding KEDA Scaling Patterns

KEDA uses different lag thresholds to determine when to scale your Kafka components:

### Scaling from 0 to 1 (Activation)
- **Trigger**: When consumer lag exceeds the `activation-lag-threshold` (default: 0)
- **Behavior**: KEDA activates the first replica when any messages are waiting in the Kafka queue
- **Use case**: Quick response to incoming events when the system is idle

### Scaling from 1 to N (Scale Up)
- **Trigger**: When consumer lag exceeds the `lag-threshold` (default: 100)
- **Behavior**: KEDA adds more consumer replicas based on the lag-to-threshold ratio
- **Formula**: `desired_replicas = min(ceil(current_lag / lag_threshold), max_scale)`

### Scaling Down and to Zero
- **Trigger**: When consumer lag falls below thresholds
- **Behavior**: KEDA waits for the `cooldown-period` (default: 30 seconds) before reducing replicas
- **Scale to zero**: Occurs when lag is below `activation-lag-threshold` for the duration of the cooldown period

### StatefulSet Pod Calculation
Each resource type (KafkaSources, Triggers, etc.) has its own dispatcher StatefulSet. Within each StatefulSet, the number of dispatcher pods is calculated as:
```
dispatcher_pods = ceil(total_consumers_for_resource_type / POD_CAPACITY)
```

Where `POD_CAPACITY` defaults to 20, meaning each dispatcher pod can handle up to 20 Kafka consumers.

**Important**: Each resource (KafkaSource, Trigger, Subscription) creates its own consumer group, and KEDA scales the number of consumers within that consumer group. All consumers for a given resource type are distributed across the dispatcher pods in that type's StatefulSet.

To maintain a **fixed minimum number of StatefulSet pods** for a resource type, calculate the total consumers needed:
```
total_consumers = sum_of_all_min_scales_for_resource_type
min_dispatcher_pods = ceil(total_consumers / POD_CAPACITY)
```

For example:
- 2 Triggers each with `min-scale: "40"` = 80 total consumers
- With default `POD_CAPACITY: 20`, this creates `ceil(80/20) = 4` dispatcher pods for the Trigger StatefulSet
- All 80 consumers are distributed across these 4 pods

## Configure Autoscaling for a Resource

If you want to customize how KEDA scales a KafkaSource, trigger, or subscription you can set annotations on the resource.

Note that the `min-scale` and `max-scale` parameters both refer to the number of Kafka consumers, not the number of dispatcher pods. The number of dispatcher pods in the StatefulSet is determined by `scale / POD_CAPACITY`, where `POD_CAPACITY` is an environment variable you can configure on the `kafka-controller` deployment, and defaults to `20`.

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
    autoscaling.eventing.knative.dev/activation-lag-threshold: "0"
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

## Manual Scaling with KEDA Disabled

When KEDA is disabled (either globally or for specific resources), you can manually control the number of StatefulSet pods by scaling the consumer group resources directly.

Each Kafka resource creates a corresponding `ConsumerGroup` resource in the same namespace that controls the number of consumers. You can manually scale these to achieve your desired pod count:

```bash
# List all consumer groups in your workload namespace
kubectl get consumergroups -n <your-namespace>

# Scale a specific consumer group to desired consumer count
kubectl scale consumergroup <consumergroup-name> --replicas=<desired-consumer-count> -n <your-namespace>
```

Consumer groups are named: `knative-trigger-<namespace>-<trigger-name>`

To calculate the desired consumer count for a target number of StatefulSet pods:
```
desired_consumer_count = target_pods × POD_CAPACITY
```

For example, to ensure 3 dispatcher pods for a Trigger named "my-trigger" in the "default" namespace:
```bash
# Set consumer count to 60 (3 pods × 20 POD_CAPACITY)
kubectl scale consumergroup knative-trigger-default-my-trigger --replicas=60 -n default
```

**Note**: Manual scaling is persistent until you re-enable KEDA autoscaling or manually change the scale again. The StatefulSet will automatically adjust its pod count based on the consumer group replica count.
