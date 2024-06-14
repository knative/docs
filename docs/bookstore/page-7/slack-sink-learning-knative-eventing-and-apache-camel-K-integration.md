# **Slack sink - Learning Knative Eventing and the Apache Camel K integration**

![image](images/image2.png)

As a bookstore owner, you aim to receive instant notifications in a Slack channel whenever a customer submits a new review comment. By leveraging Knative Eventing and Apache Camel K, you can set up an event-driven service that automates these notifications, ensuring you're always informed.

## **What Knative features will we learn about?**

- Knative's ability to connect with third-party services, such as Slack, through event-driven integration using **Apache Camel K**.

## **What does the final deliverable look like?**

When a CloudEvent with the type `moderated-comment` and with `ce-bad-word-filter` set to `bad` is sent, it triggers a message to be sent in a designated Slack channel.

## **Install prerequisites**

### **Prerequisite 1: Install Apache Camel CLI**

![image](images/image16.png)

Install the Apache Camel K CLI (`kamel`) on your local machine. You can find the installation instructions [here](https://camel.apache.org/camel-k/2.2.x/cli/cli.html){:target="_blank"}.

???+ bug "Troubleshooting"
 
      If after installation you run `kamel version` and you get an error message, you may need to add the `kamel` binary to your system's PATH. You can do this by moving the `kamel` binary to a directory that is already in your PATH, or by adding the directory where `kamel` is located to your PATH.

      ```sh
      $ export PATH=$PATH:<path-to-kamel-binary>
      ```

### **Prerequisite 2: Install Apache Camel-Kamelets**

![image](images/image13.png)

Next, install Apache Camel K on your cluster using the Apache Camel K CLI:

```sh
$ kamel install --registry docker.io --organization <your-organization> --registry-auth-username <your-username> --registry-auth-password <your-password>
```

Replace the placeholders with your actual Docker registry information.

If you are using other container registries, you may need to read more [here](https://camel.apache.org/camel-k/2.2.x/installation/registry/registry.html){:target="_blank"} for the installation.

???+ success "Verify"

    You will see this message if the installation is successful:

    ```sh
    📦 OLM is not available in the cluster. Fallback to regular installation.
    🐪 Camel K installed in namespace default
    ```

### **Prerequisite 3: Create a Slack App and Generate an Incoming Webhook URL**

![image](images/image21.png)

Follow the instructions [here](../create-slack-workspace/README.md){:target="_blank"} on how to create the Slack workspace and generate an incoming webhook URL for your designated channel where notifications will be sent to.

???+ success "Verify"

    You should have a webhook URL that looks like this:

    ```sh
    https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
    ```

    Save this URL as you will need it later.

### **Prerequisite 4: Create a Secret that stores your Slack Credentials**

![image](images/image22.png)

We are storing the webhook URL as a secret. Copy and paste your webhook URL into the file `application.properties`

???+ abstract "_/slack-sink/application.properties_"

    ```
    slack.channel=#bookstore-owner
    slack.webhook.url=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
    ```

Then run the following command to create the secret in the `/slack-sink` directory:

```sh
kubectl create secret generic slack-credentials --from-file=application.properties
```

???+ success "Verify"

    You should see this message if the secret is created successfully:

    ```sh
    secret/slack-credentials created
    ```

## **Implementation**

### **Step 0: Learn about Pipe**

![image](images/image14.png)

We use a feature called ["Pipe"](https://camel.apache.org/camel-k/2.3.x/apis/camel-k.html#_camel_apache_org_v1_Pipe){:target="_blank"} (a.k.a [KameletBinding](https://github.com/apache/camel-k/issues/2625){:target="_blank"}) in Apache Camel K to link event sources and destinations. Specifically, the Pipe connects events from our Broker, our source, to the Slack channel through a Slack sink [Kamelet](https://camel.apache.org/camel-k/2.3.x/kamelets/kamelets.html){:target="_blank"}, our destination.

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

Here, we will be connecting `book-review-broker` with a new Broker called `badword-broker`. And we will be creating a Trigger that helps us perform the filtering with the extension `badwordfilter: good`.

- 1: Append the following content to your `node-server/config/200-broker.yaml`:

???+ abstract "_node-server/config/200-broker.yaml_"

    ```yaml
    ---
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      name: badword-broker
    ```

- 2: Apply the YAML file:

    ```sh
    kubectl apply -f 200-broker.yaml
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

We are creating the Trigger to process the events that have type moderated-comment, and the extension `badwordfilter: bad` and route them to badword-broker.

**Create a Trigger:**

![image](images/image17.png)

- 1: Create a new YAML file named `node-server/config/badword-noti-trigger.yaml` and add the following content:

???+ abstract "_node-server/config/badword-noti-trigger.yaml_"

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
    kubectl apply -f node-server/config/badword-noti-trigger.yaml
    ```

    You should see this message if the Trigger is created successfully:
      
    ```
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

Create a new file named `slack-sink.yaml` and add the following content:

???+ abstract "_slack-sink/config/slack-sink.yaml_"

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
          name: bad-word-broker
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
$ kubectl apply -f slack-sink/slack-sink.yaml
```

???+ success "Verify"
      You will see this message if the configuration is created successfully:

      ```sh
      pipe.camel.apache.org/slack-sink-pipe created
      ```

      But this process will take a few seconds to complete. You can check the status of the pipe by running the following command:

      ```sh
      $ kubectl get pipe slack-sink-pipe
      ```

      ```sh
      NAME              PHASE     REPLICAS
      slack-sink-pipe   Ready     1
      ```

### **Step 4: Modify the Knative Services to disable scale to zero**

![image](images/image6.png)

In this step, we'll configure the notification delivery service to prevent it from [scaling down to zero](https://knative.dev/docs/serving/autoscaling/scale-to-zero/){:target="_blank"}, ensuring timely notifications.

!!! note
    `ksvc` stands for [Knative Service](https://knative.dev/docs/serving/services/){:target="_blank"}.

1. **Check Existing Knative Services:**

```sh
$ kubectl get ksvc
```

You should see a service named `pipe` listed:

```sh
NAME     URL                                         LATESTCREATED   LATESTREADY    READY   REASON
pipe     http://pipe.default.svc.cluster.local       pipe-00002      pipe-00002     True
```

2. **Edit the Knative Service:**

To prevent the notification service from scaling down to zero, set the minimum number of pods to keep running.

```sh
$ kubectl edit ksvc pipe
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
    $ kubectl get pods
    ```

    Periodically check the status of the pipe-deployment pods, and see whether they will disappear! If they stay there, then we are good!

### **Verification**

![image](images/image4.png)

Now, you have completed building the sample app. When you submit a comment, you should always receive a notification in your test Slack workspace, achieving the same result as shown in the demo video.

## **Conclusion**

In this tutorial, you learned how to set up an event-driven service that automates notifications to a Slack channel using Knative Eventing and Apache Camel K. By leveraging these technologies, you can seamlessly connect your applications to third-party services and facilitate real-time information exchange between them.

## **Next Step**

![image](images/image9.png)

Congratulations on successfully completing the bookstore sample app tutorial! If you want to deepen your understanding of Knative, open your bookstore front end, the demo book we used is a great starting point! Check the book ["Building Serverless Applications on Knative" by Evan Anderson.](https://www.oreilly.com/library/view/building-serverless-applications/9781098142063/){:target="_blank"}

![image](images/image20.png)

We've prepared additional challenges that build on top of the existing bookstore app for you to tackle. Some solutions are provided, while others are left open to encourage you to explore your own solutions.



[Go to Extra Challenges :fontawesome-solid-paper-plane:](../extra-challenge/README.md){ .md-button .md-button--primary }
