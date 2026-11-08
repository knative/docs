---
audience: developer
components:
  - eventing
function: reference
---

# **Slack sink - Learning Knative Eventing and the Apache Camel K integration**

![image](images/image2.png)

**Optional integration recipe — the [core Bookstore tutorial](../page-6/advanced-event-filtering.md) is already complete.** The retained examples assume its resources remain in `default` and sample commands run from `start`.

!!! warning "Pending runtime validation — not an executable follow-on lesson"
    The examples install the operator and `IntegrationPlatform` in `camel-k`, but create the Pipe, credentials Secret, and Brokers in `default`. This page has **not** established that the shown operator watches `default`, has the required permissions there, or uses the `camel-k` platform for builds in that namespace. An operator/platform showing Ready in `camel-k` does not validate that route. Do not run this recipe expecting an end-to-end result until the namespace, scope, platform, registry, and credential path have been validated together on a disposable cluster.

The intended outcome is Slack notification of reviews classified as inappropriate. The recipe adds Apache Camel K, a Camel build registry, and a Slack webhook; it does not establish delivery timing or availability. The registry `kind-registry:5000` is an example, **not** something Quickstart creates for you. Commands and examples below are retained for technical review, not evidence that this integration has been executed.

## **What Knative features will we learn about?**

- Knative's ability to connect with third-party services, such as Slack, through event-driven integration using **Apache Camel K**.

## **What does the final deliverable look like?**

The proposed route selects CloudEvents with type `moderated-comment` and the `badwordfilter` extension set to `bad` (binary HTTP header `ce-badwordfilter`) for notification in the designated Slack channel. Demonstrating that receipt is part of the pending runtime validation.

## **Install prerequisites**

### **Prerequisite 1: Install Apache Camel-Kamelets**

![image](images/image13.png)

Consult the [official installation docs](https://camel.apache.org/camel-k/2.8.x/installation/installation.html) to establish the namespace and operator scope. The retained operator-installation example uses Kustomize; it does not by itself establish reconciliation of the default-namespace Pipe:

```sh
kubectl create ns camel-k && \
kubectl apply -k 'github.com/apache/camel-k/install/overlays/kubernetes/descoped?ref=v2.8.0' --server-side
```

Now you need to setup an `IntegrationPlatform` with a container registry. You can read more about it in [the official installation docs](https://camel.apache.org/camel-k/2.8.x/installation/installation.html#integration-platform). A registry entry is only one prerequisite; platform selection for the Pipe's namespace and access to that registry still need validation. For example let's say we're using a Kind cluster with a local registry named `kind-registry` on port `5000`. Then your `IntegrationPlatform` CR will look like the following:

```yaml
apiVersion: camel.apache.org/v1
kind: IntegrationPlatform
metadata:
  name: camel-k
  namespace: camel-k # Make sure this is the namespace where your operator is running
spec:
  build:
    registry:
      address: kind-registry:5000
      insecure: true
```

Install it with one command:

```sh
cat <<EOF | kubectl apply -f -
apiVersion: camel.apache.org/v1
kind: IntegrationPlatform
metadata:
  name: camel-k
  namespace: camel-k
spec:
  build:
    registry:
      address: kind-registry:5000
      insecure: true
EOF
```

If you are using other container registries, you may need to read more in the [container registry configuration docs](https://camel.apache.org/camel-k/2.8.x/installation/registry/registry.html#how-to-configure){:target="_blank"} for Apache Camel K.

???+ success "Verify"

    Check the installation status of the operator:

    ```sh
    kubectl get deploy -n camel-k
    ```

    You will see the output:

    ```
    NAME               READY   UP-TO-DATE   AVAILABLE   AGE
    camel-k-operator   1/1     1            1           47h
    ```

    And the IntegrationPlatform:

    ```sh
    kubectl get integrationplatforms -n camel-k
    ```

    You will see the output with the registry address:

    ```sh
    NAME      PHASE   BUILD STRATEGY   PUBLISH STRATEGY   REGISTRY ADDRESS     DEFAULT RUNTIME   CAMEL VERSION
    camel-k   Ready   routine          Jib                kind-registry:5000   3.15.3            4.8.5
    ```

### **Prerequisite 2: Create a Slack App and Generate an Incoming Webhook URL**

![image](images/image21.png)

Follow the instructions [here](../create-slack-workspace/README.md){:target="_blank"} on how to create the Slack workspace and generate an incoming webhook URL for your designated channel where notifications will be sent to.

???+ success "Verify"

    You should have a webhook URL that looks like this:

    ```sh
    https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
    ```

    Save this URL as you will need it later. Treat it as a credential: do not commit it, paste it into public logs, or share it in support requests. Revoke it if exposed.

### **Prerequisite 3: Create a Secret that stores your Slack Credentials**

![image](images/image22.png)

We are storing the webhook URL as a secret. Copy and paste your webhook URL into the file `slack-sink/application.properties`

???+ abstract "_slack-sink/application.properties_"

    ```
    slack.channel=#bookstore-owner
    slack.webhook.url=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
    ```

Then run the following command from the `start` directory:

```sh
kubectl create secret generic slack-credentials --from-file=slack-sink/application.properties
```

???+ success "Verify"

    You should see this message if the secret is created successfully:

    ```sh
    secret/slack-credentials created
    ```

## **Implementation**

### **Step 0: Learn about Pipe**

![image](images/image14.png)

We use a feature called ["Pipe"](https://camel.apache.org/camel-k/2.8.x/apis/camel-k.html#_camel_apache_org_v1_Pipe){:target="_blank"} (a.k.a [KameletBinding](https://github.com/apache/camel-k/issues/2625){:target="_blank"}) in Apache Camel K to link event sources and destinations. Specifically, the Pipe connects events from our Broker, our source, to the Slack channel through a Slack sink [Kamelet](https://camel.apache.org/camel-k/2.8.x/apis/camel-k.html#_camel_apache_org_v1_Kamelet){:target="_blank"}, our destination.

![image](images/image10.png)

From the sample YAML below, you can see we are telling the pipe to filter on the events that have type "moderated-comment". Pipe will create a Trigger under the hood and route your event to slack-sink.

```yaml
apiVersion: camel.apache.org/v1
kind: Pipe
metadata:
  name: pipe
spec:
  source:
    ref:
      kind: Broker
      apiVersion: eventing.knative.dev/v1
      name: badword-broker
    properties:
      type: moderated-comment
  sink:
    ...
```

If you hope to learn more about it, check out the article [Event Sourcing with Apache Camel K and Knative Eventing by Matthias Weßendorf](https://knative.dev/blog/articles/knative-meets-apache-camel){:target="_blank"}!

### **Step 1: Create the Broker that can route "bad word" comments to Slack**

![image](images/image19.png)

This sample's Pipe source configuration selects the CloudEvent type `moderated-comment`. To select the `badwordfilter` extension as well, the sample uses a Knative Trigger before a second Broker. This demonstrates extension filtering without relying on additional Camel K source-filtering behavior; consult the Camel K version's documentation for supported options.

![image](images/image11.png)

Here, we will be connecting `bookstore-broker` with a new Broker called `badword-broker`. A Trigger selects `badwordfilter: bad` and sends only those processed events to the second Broker. Create the missing sample configuration directory first:

```sh
mkdir -p slack-sink/config
```

- 1: Create a new file named `slack-sink/config/100-broker.yaml` and add the following content:

???+ abstract "_slack-sink/config/100-broker.yaml_"

    ```yaml
    ---
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      name: badword-broker
    ```

- 2: Apply the YAML file:

    ```sh
    kubectl apply -f slack-sink/config/100-broker.yaml
    ```

You should see this message if the Broker is created successfully:

```
broker.eventing.knative.dev/badword-broker created
```

Alternatively, use the [Knative CLI `kn`](https://knative.dev/docs/client/#kn){:target="_blank"} to create the broker:

```sh
kn broker create badword-broker
```

You should see this message if the Broker is created successfully:

```
Broker 'badword-broker' successfully created in namespace 'default'.
```

???+ success "Verify"

    Run the following command to list the Brokers:
    ```sh
    kubectl get brokers
    ```

    You should see the `badword-broker` listed.
    ```
    NAME               URL                                                                                 AGE     READY   REASON
    badword-broker     http://broker-ingress.knative-eventing.svc.cluster.local/default/badword-broker     3s      True    
    bookstore-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/bookstore-broker   5h38m   True   
    ``` 


???+ bug "Troubleshooting"

    If there are issues, use the following command to diagnose:

    ```sh
    kubectl describe broker badword-broker
    ```

### **Step 2: Create Trigger that filters for bad word comments to badword-broker**

![image](images/image12.png)

We are creating the Trigger to process the events that have type `moderated-comment`, and the extension `badwordfilter: bad` and route them to `badword-broker`.

**Create a Trigger:**

![image](images/image17.png)

- 1: Append the following content to your `slack-sink/config/100-broker.yaml`:

???+ abstract "_slack-sink/config/100-broker.yaml_"

    ```yaml
    ---
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: badword-noti-trigger
    spec:
      broker: bookstore-broker
      filter:
        attributes: # Trigger will filter events based on BOTH the type and badwordfilter attribute
          type: moderated-comment # This is the filter that will be applied to the event, only events with the ce-type moderated-comment will be processed
          badwordfilter: bad # This is the filter that will be applied to the event, only events with the ce-extension badwordfilter: bad will be processed
      subscriber:
        ref:
          apiVersion: eventing.knative.dev/v1
          kind: Broker
          name: badword-broker
    ```

- 2: Apply the YAML file:

    ```sh
    kubectl apply -f slack-sink/config/100-broker.yaml
    ```

    You should see this message if the Trigger is created successfully:
      
    ```sh
    broker.eventing.knative.dev/badword-broker unchanged
    trigger.eventing.knative.dev/badword-noti-trigger created
    ```

???+ success "Verify"

    ```sh
    kubectl get triggers
    ```

    The Trigger `badword-noti-trigger` should have `READY` status as `True`.

    ```
    NAME                BROKER             SUBSCRIBER_URI                                                       AGE     READY   REASON
    db-insert-trigger   bookstore-broker   http://node-server-svc.default.svc.cluster.local/insert              5h41m   True    
    seq-reply-trigger   bookstore-broker   http://event-display.default.svc.cluster.local                       5h39m   True    
    sequence-trigger    bookstore-broker   http://sequence-kn-sequence-0-kn-channel.default.svc.cluster.local   5h39m   True    
    log-trigger         bookstore-broker   http://event-display.default.svc.cluster.local                       5h41m   True   
    badword-noti-triggerbookstore-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/badword-broker                       5h41m   True   
    ```

### **Step 3: Build the Pipe**

The proposed Pipe consumes selected events from `badword-broker` and sends them to Slack. Before applying it, the reviewer must establish the operator/platform/Secret namespace path described in the warning above.

- 1: Make sure you have your k8s secret that contains your Slack webhook Url ready. If not, refer to the [Prerequisite 3](#prerequisite-3-create-a-secret-that-stores-your-slack-credentials) section.

- 2: Prepare the YAML configuration for the Slack sink, which will forward events to your Slack channel:

![image](images/image15.png)

Create a new file named `slack-sink/config/100-slack-sink.yaml` and add the following content:

???+ abstract "_slack-sink/config/100-slack-sink.yaml_"

    ```yaml
    apiVersion: camel.apache.org/v1
    kind: Pipe
    metadata:
      name: pipe
      annotations:
        trait.camel.apache.org/mount.configs: "secret:slack-credentials"
    spec:
      source:
        ref:
          kind: Broker
          apiVersion: eventing.knative.dev/v1
          name: badword-broker
        properties:
          type: moderated-comment
      sink:
        ref:
          kind: Kamelet
          apiVersion: camel.apache.org/v1
          name: slack-sink
        properties:
          channel: ${slack.channel}
          webhookUrl: ${slack.webhook.url}
    ```

3. Apply the configuration to your Kubernetes cluster:

```sh
kubectl apply -f slack-sink/config/100-slack-sink.yaml
```

???+ success "Verify"
      You will see this message if the configuration is created successfully:

      ```sh
      pipe.camel.apache.org/pipe created
      ```

      Creation only confirms API acceptance. Inspect the Pipe's conditions and generated resources; the following is a status check, not evidence of successful build or Slack receipt:

      ```sh
      kubectl get pipe pipe
      ```

      ```sh
      NAME              PHASE     REPLICAS
      pipe              Ready     1
      ```

### **Step 4: Modify the Knative Services to disable scale to zero**

![image](images/image6.png)

**Optional scale-floor experiment, not a prerequisite for proving webhook receipt.** A [minimum scale](../../serving/autoscaling/scale-bounds.md#lower-bound) requests a lower replica bound for the applicable autoscaler; it is not a guarantee of ready capacity, timely delivery, or uptime.

!!! warning "Camel-managed configuration must persist through reconciliation"
    A direct patch or edit of a generated Knative Service is not an established persistent configuration path for this integration. Camel K may reconcile the generated resource. Configure a scale floor through the owning Camel resource's supported configuration after validating the version-specific mechanism; this page does not invent a trait setting. Do not rely on a one-time live patch or a pod staying present briefly as proof of persistent configuration.

Inspect the actual generated resources before considering this experiment:

```sh
kubectl -n default get ksvc
```

`ksvc` means [Knative Service](../../serving/services/README.md). The original example assumed a generated Service named `pipe`. Verify its name and ownership rather than assuming it exists.

??? info "Retained direct-patch example — disposable experiment only"
    If the generated Service is named `pipe`, the original patch was:

    ```sh
    kubectl -n default patch ksvc pipe --type merge -p '{"spec":{"template":{"metadata":{"annotations":{"autoscaling.knative.dev/min-scale":"1"}}}}}'
    ```

    The equivalent live edit was `kubectl -n default edit ksvc pipe`, adding this fragment:

    ```yaml
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/min-scale: "1"
    ```

    Inspect the Service template, ownership, Ready conditions, and pods after reconciliation. If the annotation does not persist, resolve configuration through the owner rather than repeatedly patching its output. Even a persistent annotation does not prove that a replica is available or that Slack delivery succeeds.

### **Verification**

![image](images/image4.png)

Runtime validation must first establish that the operator reconciles the Pipe in `default`, selects a usable platform/registry, mounts the intended Secret, and produces a Ready receiver. Then submit a distinctive test review, confirm its `moderated-comment` event has `badwordfilter: bad`, and correlate the event/receiver evidence with a message in the intended test Slack channel. A Ready Pipe, Service, or pod alone does not demonstrate webhook receipt. This validation has not been performed for the retained recipe.

## **Conclusion**

This reference retains the proposed Broker → Trigger → Broker → Camel K Pipe → Slack design and its example configuration. It remains a pending integration experiment, not a completed or validated tutorial.

## **Next Step**

![image](images/image9.png)

Return to the completed [Bookstore core outcome](../page-6/advanced-event-filtering.md). If you performed any disposable experiments, [clean up the cluster](../../getting-started/clean-up.md) and revoke the test Slack webhook when finished.

**Previous:** [Complete the core Bookstore route](../page-6/advanced-event-filtering.md) · **Optional next:** [Extra challenges](../extra-challenge/README.md)

If you want to deepen your understanding of Knative, open your bookstore front end, the demo book we used is a great starting point! Check the book ["Building Serverless Applications on Knative" by Evan Anderson.](https://www.oreilly.com/library/view/building-serverless-applications/9781098142063/){:target="_blank"}

![image](images/image20.png)

We've prepared additional challenges that build on top of the existing bookstore app for you to tackle. Some solutions are provided, while others are left open to encourage you to explore your own solutions.

[Go to Extra Challenges :fontawesome-solid-paper-plane:](../extra-challenge/README.md){ .md-button .md-button--primary }
