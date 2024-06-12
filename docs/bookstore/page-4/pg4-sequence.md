# **Create the Knative Sequence with both ML services and send the final result to the Broker and event-display**

![image](images/image8.png)

## **What Knative features will we learn about?**

- Knative Sequence

## **What does the final deliverable look like?**

![image](images/image1.png)

- Create a Knative Sequence with bad word filter service as step 1 and sentiment analysis service as step 2
- The final result is sent back to broker as reply of the sequence

## **Implementation**

### **Step 0: Learn Sequence**

Sequence provides a way to define an in-order list of functions that will be invoked. Each step can modify, filter or create a new kind of an event.

If you hope your event to pass through different services **in an order you like**, Knative Sequence is your choice.

![image](images/image3.png)


```yaml
apiVersion: flows.knative.dev/v1
kind: Sequence
metadata:
  name: sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
  steps:
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: first
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: second
  reply:
    ref:
      kind: Service
      apiVersion: serving.knative.dev/v1
      name: event-display
```

### **Step 1: Create the sequence**

![image](images/image9.png)

???+ abstract "sequence/config/100-create-sequence.yaml"
    ```yaml 
    apiVersion: flows.knative.dev/v1
    kind: Sequence
    metadata:
      name: sequence
    spec:
      channelTemplate: # Under the hood, the Sequence will create a Channel for each step in the sequence
        apiVersion: messaging.knative.dev/v1
        kind: InMemoryChannel
      steps:
        - ref: # This is the first step of the sequence, it will send the event to the bad-word-filter service
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: bad-word-filter
        - ref: # This is the second step of the sequence, it will send the event to the sentiment-analysis-app service
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: sentiment-analysis-app
      reply: # This is the last step of the sequence, it will send the event back to the broker as reply
        ref:
          kind: Broker
          apiVersion: eventing.knative.dev/v1
          name: bookstore-broker
    ```

Create the sequence yaml file and apply it to your cluster.

![image](images/image10.png)

???+ success "Verify"

    You can verify the status of the sequence very easily

    ```bash
    kubectl get sequences
    ```

    You should expect the Ready state for `sequence` to be True.
    ```
    NAME       URL                                                                  AGE    READY   REASON
    sequence   http://sequence-kn-sequence-0-kn-channel.default.svc.cluster.local   159m   True    
    ```

### **Step 2: Create the trigger that pass the event to Sequence**

![image](images/image7.png)

As the Sequence is ready to accept the request now, we need to tell the Broker to forward the events to the Sequence, so that new comments will go through our ML workflows.


???+ abstract "sequence/config/200-create-trigger.yaml"

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: sequence-trigger
    spec:
      broker: bookstore-broker
      filter:
        attributes:
          type: new-review-comment # This is the filter that will be applied to the event, only events with the ce-type new-review-comment will be processed
      subscriber:
        ref:
          apiVersion: flows.knative.dev/v1
          kind: Sequence
          name: sequence
    ```

Create the trigger yaml file and apply it to your cluster.

```
kubectl apply -f sequence/config/200-create-trigger.yaml
```

And you should see the following output:

```
trigger.eventing.knative.dev/sequence-trigger created
```


???+ success "Verify"
    You can verify the status of the trigger very easily

    ```bash
    kubectl get triggers
    ```

    You should see the Trigger in ready state.

    ```
    NAME                BROKER             SUBSCRIBER_URI                                                       AGE    READY   REASON
    seq-reply-trigger   bookstore-broker   http://event-display.default.svc.cluster.local                       162m   True    
    sequence-trigger    bookstore-broker   http://sequence-kn-sequence-0-kn-channel.default.svc.cluster.local   162m   True    
    log-trigger        bookstore-broker    http://event-display.default.svc.cluster.local                       164m   True    
    ```

    You will find out that there is an extra trigger called `seq-reply-trigger`. It is automatically created by sequence, used to send the reply back to broker.

    And until this point, **your cluster should have the following triggers** that are created by you manually.
    ![image](images/image12.png)



### **Verification**

![image](images/image11.png)

Open the log for event-display with the following command:

```bash
kubectl logs event-display-XXXXX -f
```

Type something in the comment box in the UI and click the submit button. All the events that the bookstore-broker received will be displayed in the event-display.

???+ success "Verify"

    The comment should appear in the event-display service with the following output:

    ```yaml
    ☁️cloudevents.Event
    Validation: valid
    Context Attributes,
    specversion: 1.0
    type: moderated-comment
    source: sentiment-analysis
    id: 2f703218-15d4-4ff8-b2bc-11200e209315
    time: 2024-04-21T01:26:27.608365Z
    datacontenttype: application/json
    Extensions,
    badwordfilter: bad
    knativearrivaltime: 2024-04-21T01:26:27.617405597Z
    sentimentresult: negative
    Data,
    {
        "reviewText": "XXXXXXXXXXXX",
        "badWordResult": "bad",
        "sentimentResult": "negative"
    }
    ```

## **Next Step**

![image](images/image4.png)

In this tutorial, you learned how to create a sequence to build a ML pipeline.

Next, we'll be learning how to spin up book store’s database services, while learning what will be the best case to use Knative Serving.

[Go to Deploy Database Service :fontawesome-solid-paper-plane:](../page-5/pg5-db-svc.md){ .md-button .md-button--primary }