# Logging

You can use [Fluent Bit](https://docs.fluentbit.io/), a log processor and forwarder, to collect
Kubernetes logs in a central directory.
This is not required to run Knative, but can be helpful with
[Knative Serving](/docs/serving/), which automatically deletes pods and associated logs when they are no longer needed.

Fluent Bit supports exporting to a number of other log providers. If you already have an existing log provider, for example, Splunk, Datadog, ElasticSearch, or Stackdriver, you can follow the [FluentBit documentation](https://docs.fluentbit.io/manual/pipeline/outputs) to configure log forwarders.

## Setting up logging components

Setting up log collection requires two steps:

1. Running a log forwarding DaemonSet on each node.
2. Running a collector somewhere in the cluster.

!!! tip
    In the following example, a StatefulSet is used, which stores logs on a Kubernetes PersistentVolumeClaim, but you can also use a HostPath.

### Setting up the collector

The `fluent-bit-collector.yaml` file defines a StatefulSet, as well as a Kubernetes Service which allows accessing and reading the logs from within the cluster. The supplied configuration will create the monitoring configuration in a namespace called `logging`.

!!! important
    Set up the collector before the forwarders. You will need the address of the collector when configuring the forwarders, and the forwarders may queue logs until the collector is ready.

![System diagram: forwarders and co-located collector and nginx](system.svg)

<!-- yuml.me UML rendering of:
[Forwarder1]logs->[Collector]
[Forwarder2]logs->[Collector]

// Add notes
[Collector]->[shared volume]
[nginx]-[shared volume]
-->

#### Procedure

1. Apply the configuration by entering the command:

    ```bash
    kubectl apply -f https://github.com/knative/docs/raw/main/docs/serving/observability/logging/fluent-bit-collector.yaml
    ```
    The default configuration will classify logs into:

    - Knative services, or pods with an `app=Knative` label.
    - Non-Knative apps.

    !!! note
        Logs default to logging with the pod name; this can be changed by updating the `log-collector-config` ConfigMap before or after installation.

    !!! warning
        After the ConfigMap is updated, you must restart Fluent Bit. You can do this by deleting the pod and letting the StatefulSet recreate it.

1. To access the logs through your web browser, enter the command:

    ```bash
    kubectl port-forward --namespace logging service/log-collector 8080:80
    ```

3. Navigate to `http://localhost:8080/`.

4. Optional: You can open a shell in the `nginx` pod and search the logs using Unix tools, by entering the command:

    ```bash
    kubectl exec --namespace logging --stdin --tty --container nginx log-collector-0
    ```

### Setting up the forwarders

See the [Fluent Bit](https://docs.fluentbit.io/manual/installation/kubernetes) documentation to set up a Fluent Bit DaemonSet that forwards logs to ElasticSearch by default.

When you create a ConfigMap during the installation steps, you must:

- Replace the ElasticSearch configuration with the [`fluent-bit-configmap.yaml`](fluent-bit-configmap.yaml), or
- Add the following block to the ConfigMap, and update the
`@INCLUDE output-elasticsearch.conf` to be `@INCLUDE output-forward.conf`:

    ```yaml
    output-forward.conf: |
      [OUTPUT]
          Name            forward
          Host            log-collector.logging
          Port            24224
          Require_ack_response  True
    ```

### Setting up a local collector

!!! warning
    This procedure describes a development environment setup and is not suitable for production use.

If you are using a local Kubernetes cluster for development, you can create a `hostPath` PersistentVolume to store the logs on your desktop operating system. This allows you to use your usual desktop tools on the files without needing Kubernetes-specific tools.

The `PersistentVolumeClaim` will look similar to the following:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: shared-logs
  labels:
    app: logs-collector
spec:
  accessModes:
    - "ReadWriteOnce"
  storageClassName: manual
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: logs-log-collector-0
    namespace: logging
  capacity:
    storage: 5Gi
  hostPath:
    path: <see below>
```

!!! note
    The `hostPath` will vary based on your Kubernetes software and host operating system.

You must update the StatefulSet `volumeClaimTemplates` to reference the `shared-logs` volume, as shown in the following example:

```yaml
volumeClaimTemplates:
  metadata:
    name: logs
  spec:
    accessModes: ["ReadWriteOnce"]
    volumeName: shared-logs
```

### Kind

When creating your cluster, you must use a `kind-config.yaml` and specify
`extraMounts` for each node, as shown in the following example:

```yaml
apiversion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: ./logs
        containerPath: /shared/logs
  - role: worker
    extraMounts:
      - hostPath: ./logs
        containerPath: /shared/logs
```

You can then use `/shared/logs` as the `spec.hostPath.path` in your
PersistentVolume. Note that the directory path `./logs` is relative to the
directory that the Kind cluster was created in.

### Docker Desktop

Docker desktop automatically creates some shared mounts between the host and the
guest operating systems, so you only need to know the path to your home
directory. The following are some examples for different operating systems:

| Host OS | `hostPath`                               |
| ------- | ---------------------------------------- |
| Mac OS  | `/Users/${USER}`                         |
| Windows | `/run/desktop/mnt/host/c/Users/${USER}/` |
| Linux   | `/home/${USER}`                          |

### Minikube

Minikube requires an explicit command to [mount a directory](https://minikube.sigs.k8s.io/docs/handbook/mount/) into the virtual machine (VM) running Kubernetes.

The following command mounts the `logs` directory inside the current directory onto `/mnt/logs` in the VM:

```bash
minikube mount ./logs:/mnt/logs
```

You must also reference `/mnt/logs` as the `hostPath.path` in the PersistentVolume.
