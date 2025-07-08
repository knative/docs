# Monitoring Virtual Machines with Knative Eventing

**Authors: Robert Guske, Senior Specialist Solution Architect OpenShift @ Red Hat, Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In this blog post you will learn how to easily monitor state of KubeVirt VMs with Knative Eventing's powerful building blocks._

Event-Driven Architecture (EDA) and the use of event sources fundamentally transform how applications interact, fostering a highly decoupled and scalable environment where services react dynamically to changes. By abstracting the origin of information, event sources empower systems to integrate seamlessly and respond in real-time to a vast array of occurrences across diverse platforms.

## The Knative ApiServerSource

Knative `ApiServerSource` is a Knative Eventing Kubernetes custom resource that acts as an event source. Its primary function is to listen for events emitted by the Kubernetes API server and forward them as [CloudEvents](https://cloudevents.io/) to a designated [sink](https://knative.dev/docs/eventing/sinks/). CloudEvents is a specification for describing event data in common formats to provide interoperability across services, platforms and systems.

Some common use cases include:

* Auditing and monitoring: Triggering actions or notifications when specific custom Kubernetes resources are _created_, _updated_, or _deleted_.
* Automating workflows: Initiating a serverless function when a new Pod is _deployed_, a Deployment _scales_, or a ConfigMap is _modified_.
* Integrating with external systems: Sending Kubernetes events to data warehouses or databases, AI applications or even logging systems for analysis.

In order to quickly create a `ApiServerSource`, follow the official guidance here: [Creating an ApiServerSource object](https://knative.dev/docs/eventing/sources/apiserversource/getting-started/).

The following is an example of an `ApiServerSource` configuration which only sends emitted events of the Kubernetes API server related to `kind: VirtualMachine` to the default [Channel based Broker](https://knative.dev/docs/eventing/brokers/broker-types/channel-based-broker/).

```yaml
kubectl create -f - <<EOF
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: apiserversource
  labels:
    app: apiserversource
spec:
  mode: Resource
  resources:
    - apiVersion: kubevirt.io/v1
      kind: VirtualMachine
  serviceAccountName: events-sa
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: broker-apiserversource
EOF
```

### Event Routing

The Channel based Broker (`MTChannelBasedBroker`) facilitates the routing and delivery of events within a Kubernetes cluster and is shipped by default with Knative Eventing. However, users should prefer Broker implementations like e.g. Apache Kafka or RabbitMQ Broker over the `MTChannelBasedBroker` and Channel combination because it is usually more efficient and reliable.

The following configuration is used for the use case described in this blog post:

```yaml
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: broker-apiserversource
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
  delivery:
    backoffDelay: PT0.2S
    backoffPolicy: exponential
    retry: 10
EOF
```

At this stage, the event flow is like:

`Kubernetes API server` <-- `ApiServerSource` --> `Broker`

## Entering KubeVirt

As organizations continue to adopt microservices and containers, there’s still a need for legacy workloads that require virtual machines (VM). Enter [KubeVirt](https://kubevirt.io/) — the fast evolving open-source solution that integrates virtual machine management directly into Kubernetes.

KubeVirt allows you to run, manage, and scale virtual machines just as easily as you would containers, all within the same Kubernetes cluster. It enables teams to seamlessly combine the best of both worlds leveraging Kubernetes powerful orchestration capabilities for containerized workloads while still supporting VMs for legacy systems and specialized applications.

It’s a game-changer for teams looking to modernize their infrastructure without sacrificing compatibility with existing workloads.

## A Real-World Use Case

Now that KubeVirt allows you to run virtual machine workloads on your Kubernetes environment, imagine how your operational efficiency can be increased significantly leveraging the power of eventing. Envision a scenario where virtual machines are created, updated or deleted and every time this occurs, a Configuration Management Database (CMDB) will be updated to reflect the changes.

This use case can be elegantly handled with Knative Eventing and Functions-as-a-Service (FaaS). Whenever one of the aforementioned operations happened, an event will be created by the Kubernetes API Server, will be processed through Knative, including triggering and invoking a function (business logic) and will ultimtaley update the CMDB in real-time.

Picturing: _VM Operation_ --> _Event Creation_ --> _Event Processing_ --> _Automation_

### Trimmimg the fat from the Event-Payload

As mentioned in the beginning, the `ApiServerSource` CR is listening for events and forwards them as CloudEvents to an addressable or a callable resource. In Knative this is called a `sink` which can be e.g. `Brokers`, `Channels` or `Knative Services` (applications). The challenge though is, that the produced events are data-heavy and making downstream processing tricky. "Downstream processing" != the further processing of the received data.

Example of a virtual machine creation event (event type: `dev.knative.apiserver.resource.add`):

```code
Context Attributes,
  specversion: 1.0
  type: dev.knative.apiserver.resource.add
  source: https://172.30.0.1:443
  subject: /apis/kubevirt.io/v1/namespaces/kubevirt-eventing/virtualmachines/rhel-vm-2
  id: 5508cafb-3332-4709-a1b1-a8657111d82c
  time: 2025-07-07T13:02:18.124604417Z
  datacontenttype: application/json
Extensions,
  apiversion: kubevirt.io/v1
  kind: VirtualMachine
  knativearrivaltime: 2025-07-07T13:02:18.132189108Z
  name: rhel-vm-2
  namespace: kubevirt-eventing
Data,
  {
    "apiVersion": "kubevirt.io/v1",
    "kind": "VirtualMachine",
    "metadata":
      "creationTimestamp": "2025-07-07T13:02:18Z",

// output omitted

      ],
      "name": "rhel-vm-2",
      "namespace": "kubevirt-eventing",
      "resourceVersion": "35172905",
      "uid": "17160b0a-9f0b-461c-9d6c-f1e477dacf93"
    },

// output omitted

        "spec": {
          "architecture": "amd64",
          "domain": {
            "cpu": {
              "cores": 4,
              "sockets": 2,
              "threads": 1
            },

/// output omitted

              ],
              "interfaces": [
                {
                  "bridge": {},
                  "name": "default"
                }
              ]
            },
            "machine": {
              "type": "pc-q35-rhel9.2.0"
            },
            "memory": {
              "guest": "8Gi"
            },
            "resources": {}
          },
          "networks": [
            {
              "name": "default",
              "pod": {}
            }
          ],

/// output omitted
```

The original event can be seen here: [rhel9-vm-creation-event](https://raw.githubusercontent.com/rguske/knative-functions/refs/heads/main/kn-py-vmdata-psql-fn/test/vm-creation-event-origin.json)

The following recording is visualizing the non-customized incoming `dev.knative.apiserver.resource.add` event after a virtual machine creation operation happened.

[![asciicast-kubevirt-eventing-origin](https://asciinema.org/a/726712.svg)](https://asciinema.org/a/726712)

### Event Transformation with a low-code Approach

In Knative Eventing version 1.18.0, the new `EventTransform` API CRD [got introduced](https://knative.dev/blog/releases/announcing-knative-v1-18-release/) which will be the needed scalpel in your toolbox to trimm the "data-heavy" data playload to your tailored requirements. It allows you to modify event attributes, extract data from event payloads, and reshape events to fit different systems requirements. `EventTransform` is designed to be a flexible component in your event-driven architecture that can be placed at various points in your event flow to facilitate seamless integration between diverse systems.

Coming back to our use case - the new functionality will support us with extracting exactly the data in which we are interested in to feet our CMDB with proper data.

Create the `EventTransform` CR:

```yaml
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: vmdata-transform
spec:
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: broker-transformer
  jsonata:
    expression: |
      {
        "specversion": specversion,
        "type": type,
        "source": source,
        "subject": subject,
        "id": id,
        "time": time,
        "kind": kind,
        "name": name,
        "namespace": namespace,
        "cpucores": data.spec.template.spec.domain.cpu.cores,
        "cpusockets": data.spec.template.spec.domain.cpu.sockets,
        "memory": data.spec.template.spec.domain.memory.guest,
        "datasource": data.spec.dataVolumeTemplates.spec.storage.resources.resources.storage,
        "storageclass": data.spec.dataVolumeTemplates.spec.storage.storageClassName,
        "network": data.spec.template.spec.networks.name
      }
EOF
```

As the example shows, it'll extract values from the original event data and creates a new one. [JSONata](https://jsonata.org/), a lightweight query and transformation language is used for that. Give it a try!

Having this in-place, the order of the event-flow got extended:

`Kubernetes API server` <-- `ApiServerSource` --> `Broker` --> `EventTransform`

Once this is implemented and a new virtual machine was created, the event payload will be much more simplified.

Example custom event payload:

```json
Context Attributes,
  specversion: 1.0
  type: dev.knative.apiserver.resource.add
  source: https://172.30.0.1:443
  subject: /apis/kubevirt.io/v1/namespaces/kubevirt-eventing/virtualmachines/rhel-vm-2
  id: 5508cafb-3332-4709-a1b1-a8657111d82c
  time: 2025-07-07T13:02:18.124Z
Extensions,
  cpucores: 4
  cpusockets: 2
  kind: VirtualMachine
  knativearrivaltime: 2025-07-07T13:02:53.385732787Z
  memory: 8Gi
  name: rhel-vm-2
  namespace: kubevirt-eventing
  network: default
  storageclass: coe-netapp-san
```

This tailored event will perfectly serve our use case and makes the processing for functions much easier.

The following recording is visualizing the customized event using the `EventTransform` CR.

[![asciicast-kubevirt-eventing-transform](https://asciinema.org/a/726713.svg)](https://asciinema.org/a/726713)

## Bringing It All (Event-Driven) Together

With having almost all necessary components ready-to-go it is time to bring the use case "Monitoring Virtual Machines with Knative Eventing" into live. The final missing pieces are the function, deployed as a Knative Service (`ksvc`), itself with the corresponding `triggers`. The `triggers` will do the routing of events from a Broker to a Sink. Think of it like: "When an event matching this filter arrives in the broker, send it to this service (e.g. a function)."

Remember, we want our CMDB database automatically and event-driven updated based on virtuial machine creation or deletion operations. Important is, that we are only interested in specific data which should be feet into the DB.

The following output shows a yet empty PostgreSQL DB. Notce that the columns are matching the jsonata expressions from the configured `EventTransform` CR.

```code
psql -U postgres -h 10.32.98.110 -p 5432 -d vmdb -c 'SELECT * FROM "virtual_machines"'
Password for user postgres:
 type | id | kind | name | namespace | time | cpucores | cpusockets | memory | storageclass | network
------+----+------+------+-----------+------+----------+------------+--------+--------------+---------
(0 rows)
```

### Deploy the Function

The business-logic in this example is written in Python. It'll process the incoming tailored event, establish a connection to the PostgreSQL DB and will write the desired data into the columns of the DB `vmdb`. Keep in mind, that you have the freedom of deciding in which programming language you write your business-logic.

The code for the used function can be found on Github here: [KubeVirt PostgreSQL Knative Function Example](https://github.com/rguske/knative-functions/tree/main/kn-py-vmdata-psql-fn)

A `secret` needs to be created beforehand to store the database related sensible data which will be picked up by the function during its execution.

```python
## snipped handler.py
DB_HOST = os.getenv('DB_HOST')
DB_PORT = int(os.getenv('DB_PORT', 5432))
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')

[...]
```

Deploying the function as well as the associated triggers:

```code
kubectl create -f https://raw.githubusercontent.com/rguske/knative-functions/refs/heads/main/kn-py-vmdata-psql-fn/function.yaml
```

Validating the successful creation of the function using `kubectl` or `kn`:

```code
kubectl get ksvc
NAME                                   URL                                                                                                      LATESTCREATED                                LATESTREADY                                  READY   REASON
kn-py-psql-vmdata-fn                   https://kn-py-psql-vmdata-fn-kubevirt-eventing.apps.ocp1.stormshift.coe.muc.redhat.com                   kn-py-psql-vmdata-fn-00001                   kn-py-psql-vmdata-fn-00001                   True
```

```code
kn service list
NAME                                   URL                                                                                                      LATEST                                       AGE     CONDITIONS   READY   REASON
kn-py-psql-vmdata-fn                   https://kn-py-psql-vmdata-fn-kubevirt-eventing.apps.ocp1.stormshift.coe.muc.redhat.com                   kn-py-psql-vmdata-fn-00001                   5h3m    3 OK / 3     True
```

Also validate the conditions of the Triggers:

```code
kubectl get triggers
NAME                                           BROKER                   SUBSCRIBER_URI                                                                    AGE     READY   REASON
trigger-kn-py-psql-vmdata-fn-add               broker-transformer       http://kn-py-psql-vmdata-fn.kubevirt-eventing.svc.cluster.local                   5h36m   True
trigger-kn-py-psql-vmdata-fn-delete            broker-transformer       http://kn-py-psql-vmdata-fn.kubevirt-eventing.svc.cluster.local                   5h36m   True
```

```code
kn trigger list
NAME                                           BROKER                   SINK                                                             AGE     CONDITIONS   READY   REASON
trigger-kn-py-psql-vmdata-fn-add               broker-transformer       ksvc:kn-py-psql-vmdata-fn                                        5h38m   7 OK / 7     True
trigger-kn-py-psql-vmdata-fn-delete            broker-transformer       ksvc:kn-py-psql-vmdata-fn                                        5h38m   7 OK / 7     True
```

Fasten your seatbelt 🚀 The complete event-flow is in-place:

`Kubernetes API server` <-- `ApiServerSource` --> `Broker` --> `EventTransform` --> `Broker` --> `Trigger` --> `Function`

## Watch the Show

The orchestra is complete and our function is waiting for the starting signal to kick-off.

Illustration of the overall use case:

![kubevirt-meets-eventing-flow](./images/kubevirt-meets-eventing-flow.png)

Watch the show via the following recording:

[![asciicast-kubevirt-eventing-final](https://asciinema.org/a/726717.svg)](https://asciinema.org/a/726717)

## Conclusion

Monitoring virtual machines in a modern, cloud-native environment becomes significantly more efficient and responsive when leveraging Knative Eventing. By tapping into Kubernetes-generated events and using Knative as the event-processing backbone, we can trigger lightweight, event-driven functions that update a database in real-time. This architecture not only decouples components and improves scalability but also ensures that your VM metadata stays current without the need for constant polling or heavy integration logic. With this approach, you lay the foundation for a reactive, extensible system that can easily adapt to new event types or downstream consumers as your infrastructure grows.

To learn more about Knative Eventing visit the documentation on our website or join our CNCF Slack channel #knative-eventing!
