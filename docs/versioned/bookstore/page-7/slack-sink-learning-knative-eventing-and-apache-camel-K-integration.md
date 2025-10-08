---
audience: developer
components:
  - eventing
function: tutorial
---

# **Slack sink - Learning Knative Eventing and the Apache Camel K integration**

![image](images/image2.png)

As a bookstore owner, you aim to receive instant notifications in a Slack channel whenever a customer submits a new review comment. By leveraging Knative Eventing and Apache Camel K, you can set up an event-driven service that automates these notifications, ensuring you're always informed.

## **What Knative features will we learn about?**

- Knative's ability to connect with third-party services, such as Slack, through event-driven integration using **Apache Camel K**.

## **What does the final deliverable look like?**

When a CloudEvent with the type `moderated-comment` and with `ce-bad-word-filter` set to `bad` is sent, it triggers a message to be sent in a designated Slack channel.

## **Install prerequisites**

### **Prerequisite 1: Install Apache Camel-Kamelets**

![image](images/image13.png)

Install Apache Camel K operator on your cluster using any of the methods listed in [the official installation docs](https://camel.apache.org/camel-k/2.8.x/installation/installation.html). We will use the installation via Kustomize:

```sh
kubectl create ns camel-k && \
kubectl apply -k github.com/apache/camel-k/install/overlays/kubernetes/descoped?ref=v2.8.0 --server-side
```

Now you need to setup an `IntegrationPlatform` with a container registry. You can read more about it in [the official installation docs](https://camel.apache.org/camel-k/2.8.x/installation/installation.html#integration-platform). For all our needs we only need to create the `IntegrationPlatform` CR with a container registry entry. For example let's say we're using a Kind cluster with a local registry named `kind-registry` on port `5000`. Then your `IntegrationPlatform` CR will look like the following:

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
    kubectl get integrationplatforms -n camel-k
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

    Save this URL as you will need it later.

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

In the current implementation using Apache Camel K, we **can only filter based on the CloudEvent's type**, such as moderated-comment. Filtering based on event extensions, such as `badwordfilter: good`, is not yet supported. This feature will be available in a future update of Apache Camel K. But we can still use an alternative way to achieve this!

![image](images/image11.png)

Here, we will be connecting `bookstore-broker` with a new Broker called `badword-broker`. And we will be creating a Trigger that helps us perform the filtering with the extension `badwordfilter: good`.

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

This setup automatically sends notifications to Slack whenever a new comment that contains "bad word" occur, streamlining the flow of information.

- 1: Make sure you have your k8s secret that contains your Slack webhook Url ready. If not, refer to the [Prerequisite 3](#prerequisite-3-create-a-slack-app-and-generate-an-incoming-webhook-url) section.

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

      But this process will take a few seconds to complete. You can check the status of the pipe by running the following command:

      ```sh
      kubectl get pipe pipe
      ```

      ```sh
      NAME              PHASE     REPLICAS
      pipe              Ready     1
      ```

### **Step 4: Modify the Knative Services to disable scale to zero**

![image](images/image6.png)

In this step, we'll configure the notification delivery service to prevent it from [scaling down to zero](https://knative.dev/docs/serving/autoscaling/scale-to-zero/){:target="_blank"}, ensuring timely notifications.

!!! note
    `ksvc` stands for [Knative Service](https://knative.dev/docs/serving/services/){:target="_blank"}.

1. **Check Existing Knative Services:**

```sh
kubectl get ksvc
```

You should see a service named `pipe` listed:

```sh
NAME     URL                                         LATESTCREATED   LATESTREADY    READY   REASON
pipe     http://pipe.default.svc.cluster.local       pipe-00002      pipe-00002     True
```

2. **Edit the Knative Service:**

To prevent the notification service from scaling down to zero, set the minimum number of pods to keep running.

```sh
kubectl patch ksvc pipe --type merge -p '{"spec":{"template":{"metadata":{"annotations":{"autoscaling.knative.dev/min-scale":"1"}}}}}'
```

Or use the edit command:

```sh
kubectl edit ksvc pipe
```

Add the following annotation:

```yaml
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/min-scale: "1"
```

This configuration ensures that Knative will always maintain at least one instance of the service running.

???+ success "Verify"

    ```sh
    kubectl get pods
    ```

    Periodically check the status of the pipe-deployment pods, and see whether they will disappear! If they stay there, then we are good!

### **Verification**

![image](images/image4.png)

Now, you have completed building the sample app. When you submit a "bad" comment, you should receive a notification in your test Slack workspace, achieving the same result as shown in the demo video.

## **Conclusion**

In this tutorial, you learned how to set up an event-driven service that automates notifications to a Slack channel using Knative Eventing and Apache Camel K. By leveraging these technologies, you can seamlessly connect your applications to third-party services and facilitate real-time information exchange between them.

## **Next Step**

![image](images/image9.png)

Congratulations on successfully completing the bookstore sample app tutorial! If you want to deepen your understanding of Knative, open your bookstore front end, the demo book we used is a great starting point! Check the book ["Building Serverless Applications on Knative" by Evan Anderson.](https://www.oreilly.com/library/view/building-serverless-applications/9781098142063/){:target="_blank"}

![image](images/image20.png)

We've prepared additional challenges that build on top of the existing bookstore app for you to tackle. Some solutions are provided, while others are left open to encourage you to explore your own solutions.

[Go to Extra Challenges :fontawesome-solid-paper-plane:](../extra-challenge/README.md){ .md-button .md-button--primary }
