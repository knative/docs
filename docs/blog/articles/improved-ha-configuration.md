# Improving HA configuration for Knative workloads

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In this blog post you will learn how to use the Knative Operator to maintain a fine-grain configuration for high availability of Knative workloads._

The [Knative Operator](https://knative.dev/docs/install/operator/knative-with-operators/) gives you a declarative API to describe your Knative Serving and Eventing installation. The `spec` field has several properties to define the desired behavior.

### A convenient global configuration for high availability

Take a look at the following installation manifest:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  high-availability:
    replicas: 3
```

This configures Knative Eventing in the `knative-eventing` namespace, and defines that all workloads, managed by the Operator, do require a replica set of `3` pods. Let's have a look:

```bash
kubectl get deployments.apps -n knative-eventing 
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
eventing-controller     3/3     3            3           58s
eventing-webhook        3/3     3            3           57s
imc-controller          3/3     3            3           53s
imc-dispatcher          3/3     3            3           52s
mt-broker-controller    3/3     3            3           51s
mt-broker-filter        3/3     3            3           51s
mt-broker-ingress       3/3     3            3           51s
```

For each workload we do see exactly three deployements. Now, take a detailed look at the above shell snippet. You will notice that for the `InMemoryChannel` we do have `6` deployments: `3` for each, the `controller` and the `dispatcher` data-plane. This is not always what you want, since the `InMemoryChannel` is more often used as a tool during development, while in production scenarios other worksloads, like the [Knative Broker](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/) or [Knative Channel](https://knative.dev/docs/eventing/configuration/kafka-channel-configuration/) implementations for Apache Kafka are being used. 

### Fine tuning the HA configuration with workload overrides

Now here is where the `workloads` fields comes into place. The `workloads` field allows administrator to perform a more fine grain tuning of each workload, managed by the Knative Operator. Details on the configuration options can be found in the [documentation](https://knative.dev/docs/install/operator/configuring-serving-cr/#override-system-deployments).

Take a look at the modified manifest:

```yaml
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  high-availability:
    replicas: 3
  workloads:
  - name: imc-controller
    replicas: 1  
  - name: imc-dispatcher
    replicas: 1  
```

For the `imc-controller` and `imc-dispatcher` we have now done an override of the global default, and have reduced it to exactly one deployment for each:

```bash
kubectl get deployments.apps -n knative-eventing
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
eventing-controller     3/3     3            3           9m31s
eventing-webhook        3/3     3            3           9m30s
imc-controller          1/1     1            1           9m26s
imc-dispatcher          1/1     1            1           9m25s
mt-broker-controller    3/3     3            3           9m24s
mt-broker-filter        3/3     3            3           9m24s
mt-broker-ingress       3/3     3            3           9m24s
```

We could even set the replica to `0`, if the system would not use any `InMemoryChannel` in this example.

### Conclusion

While the `high-availability` offers a nice and easy to use API for defining high availability configuration for the workloads of Knative, the `workloads` is a nice option to adjust and optimize the installation. While the `workloads` is a little more complex to configure, since it allows a _per workload_ override for production systems it is recommended to use this to adjust each workload on its exacts needs, rather than relying on global defaults, which may look promising only in the beginning.
