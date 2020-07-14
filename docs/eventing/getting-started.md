---
title: "Getting Started with Knative Eventing"
linkTitle: "Getting started"
weight: 9
type: "docs"
---

After you install Knative Eventing, you can create, send, and verify events.
This guide shows how you can use a basic workflow for managing events.

Before you start to manage events, you must create the objects needed to
transport the events.

## Creating a Knative Eventing namespace

Namespaces are used to group together and organize your Knative resources.
<!--TODO: Add documentation about namespaces to core docs?-->

Create a new namespace called `event-example` by entering the following command:

```
kubectl create namespace event-example
```

## Add a broker to the namespace

The [broker](./broker/README.md#broker) allows you to route events to different event sinks or consumers.

1. Add a broker named `default` to your namespace by entering the following command:

    ```
    kubectl create -f - <<EOF
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
     name: default
     namespace: event-example
    EOF
    ```

1. Verify that the broker is working correctly, by entering the following command:

    ```
    kubectl --namespace event-example get Broker default
    ```

    This shows information about your broker. If the broker is working correctly, it shows a `READY` status of `True`:

    ```
    NAME      READY   REASON   URL                                                        AGE
    default   True             http://default-broker.event-example.svc.cluster.local      1m
    ```

    If `READY` is `False`, wait a few moments and then run the command again.
    If you continue to receive the `False` status, see the [Debugging Guide](./debugging/README.md) to troubleshoot the issue.

## Creating event consumers

In this step, you create two event consumers, `hello-display` and `goodbye-display`, to
demonstrate how you can configure your event producers to target a specific consumer.

1. To deploy the `hello-display` consumer to your cluster, run the following
   command:

     ```
     kubectl --namespace event-example apply --filename - << END
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: hello-display
     spec:
       replicas: 1
       selector:
         matchLabels: &labels
           app: hello-display
       template:
         metadata:
           labels: *labels
         spec:
           containers:
             - name: event-display
               image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display

     ---

     kind: Service
     apiVersion: v1
     metadata:
       name: hello-display
     spec:
       selector:
         app: hello-display
       ports:
       - protocol: TCP
         port: 80
         targetPort: 8080
     END
     ```

1. To deploy the `goodbye-display` consumer to your cluster, run the following
   command:

     ```
     kubectl --namespace event-example apply --filename - << END
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: goodbye-display
     spec:
       replicas: 1
       selector:
         matchLabels: &labels
           app: goodbye-display
       template:
         metadata:
           labels: *labels
         spec:
           containers:
             - name: event-display
               # Source code: https://github.com/knative/eventing-contrib/tree/master/cmd/event_display
               image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display

     ---

     kind: Service
     apiVersion: v1
     metadata:
       name: goodbye-display
     spec:
       selector:
         app: goodbye-display
       ports:
       - protocol: TCP
         port: 80
         targetPort: 8080
     END
     ```

1. Verify that the event consumers are working by entering the following command:
     ```
     kubectl --namespace event-example get deployments hello-display goodbye-display
     ```
   This lists the `hello-display` and `goodbye-display` consumers that you
   deployed:
     ```
     NAME              READY   UP-TO-DATE   AVAILABLE   AGE
     hello-display     1/1     1            1           26s
     goodbye-display   1/1     1            1           16s
     ```
   The number of replicas in the **READY** column should match the number of replicas in the **AVAILABLE** column.
   If the numbers do not match, see the [Debugging Guide](./debugging/README.md) to troubleshoot the issue.

## Creating triggers

A [trigger](./broker/README.md#trigger) defines the events that each event consumer receives.
Brokers use triggers to forward events to the correct consumers.
Each trigger can specify a filter that enables selection of relevant events based on the Cloud Event context attributes.

1. Create a trigger by entering the following command:
   ```
   kubectl --namespace event-example apply --filename - << END
   apiVersion: eventing.knative.dev/v1
   kind: Trigger
   metadata:
     name: hello-display
   spec:
     broker: default
     filter:
       attributes:
         type: greeting
     subscriber:
       ref:
        apiVersion: v1
        kind: Service
        name: hello-display
   END
   ```
   The command creates a trigger that sends all events of type `greeting` to
   your event consumer named `hello-display`.

1. To add a second trigger, enter the following command:
   ```
   kubectl --namespace event-example apply --filename - << END
   apiVersion: eventing.knative.dev/v1
   kind: Trigger
   metadata:
     name: goodbye-display
   spec:
     broker: default
     filter:
       attributes:
         source: sendoff
     subscriber:
       ref:
        apiVersion: v1
        kind: Service
        name: goodbye-display
   END
   ```
   The command creates a trigger that sends all events of source `sendoff` to
   your event consumer named `goodbye-display`.

1. Verify that the triggers are working correctly by running the following
   command:
   ```
   kubectl --namespace event-example get triggers
   ```
   This returns the `hello-display` and `goodbye-display` triggers that you
   created:
   ```
   NAME                   READY   REASON   BROKER    SUBSCRIBER_URI                                                                 AGE
   goodbye-display        True             default   http://goodbye-display.event-example.svc.cluster.local/                        9s
   hello-display          True             default   http://hello-display.event-example.svc.cluster.local/                          16s
   ```
    If the triggers are correctly configured, they will be ready and pointing to the correct broker (`default`) and `SUBSCRIBER_URI`.

    The `SUBSCRIBER_URI` has a value similar to `triggerName.namespaceName.svc.cluster.local`.
    The exact value depends on the broker implementation.
    If this value looks incorrect, see the [Debugging Guide](./debugging/README.md) to troubleshoot the issue.

## Creating a pod as an event producer

This guide uses `curl` commands to manually send individual events as HTTP requests to the broker, and demonstrate how these events are received by the correct event consumer.

The broker can only be accessed from within the cluster where Knative Eventing is installed. You must create a pod within that cluster to act as an event producer that will execute the `curl` commands.

To create a pod, enter the following command:
```
kubectl --namespace event-example apply --filename - << END
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: curl
  name: curl
spec:
  containers:
    # This could be any image that we can SSH into and has curl.
  - image: radial/busyboxplus:curl
    imagePullPolicy: IfNotPresent
    name: curl
    resources: {}
    stdin: true
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    tty: true
END
```

## Sending events to the broker

1. SSH into the pod by running the following command:
  ```
    kubectl --namespace event-example attach curl -it
  ```
  You will see a prompt similar to the following:
  ```
      Defaulting container name to curl.
      Use 'kubectl describe pod/ -n event-example' to see all of the containers in this pod.
      If you don't see a command prompt, try pressing enter.
      [ root@curl:/ ]$
  ```

1. Make a HTTP request to the broker. To show the various types of events you can send, you will make three requests:
  - To make the first request, which creates an event that has the `type`
     `greeting`, run the following in the SSH terminal:
     ```
     curl -v "http://default-broker.event-example.svc.cluster.local" \
       -X POST \
       -H "Ce-Id: say-hello" \
       -H "Ce-Specversion: 1.0" \
       -H "Ce-Type: greeting" \
       -H "Ce-Source: not-sendoff" \
       -H "Content-Type: application/json" \
       -d '{"msg":"Hello Knative!"}'
     ```
     When the `Broker` receives your event, `hello-display` will activate and send
     it to the event consumer of the same name.
     If the event has been received, you will receive a `202 Accepted` response
     similar to the one below:

     ```
     < HTTP/1.1 202 Accepted
     < Content-Length: 0
     < Date: Mon, 12 Aug 2019 19:48:18 GMT
     ```
  - To make the second request, which creates an event that has the `source`
     `sendoff`, run the following in the SSH terminal:

     ```sh
     curl -v "http://default-broker.event-example.svc.cluster.local" \
       -X POST \
       -H "Ce-Id: say-goodbye" \
       -H "Ce-Specversion: 1.0" \
       -H "Ce-Type: not-greeting" \
       -H "Ce-Source: sendoff" \
       -H "Content-Type: application/json" \
       -d '{"msg":"Goodbye Knative!"}'
     ```
     When the `Broker` receives your event, `goodbye-display` will activate and
     send the event to the event consumer of the same name.
     If the event has been received, you will receive a `202 Accepted` response
     similar to the one below:
     ```
     < HTTP/1.1 202 Accepted
     < Content-Length: 0
     < Date: Mon, 12 Aug 2019 19:48:18 GMT
     ```
  - To make the third request, which creates an event that has the `type`
     `greeting` and the`source` `sendoff`, run the following in the SSH terminal:
     ```
     curl -v "http://default-broker.event-example.svc.cluster.local" \
       -X POST \
       -H "Ce-Id: say-hello-goodbye" \
       -H "Ce-Specversion: 1.0" \
       -H "Ce-Type: greeting" \
       -H "Ce-Source: sendoff" \
       -H "Content-Type: application/json" \
       -d '{"msg":"Hello Knative! Goodbye Knative!"}'
     ```
     When the broker receives your event, `hello-display` and `goodbye-display`
     will activate and send the event to the event consumer of the same name.
     If the event has been received, you will receive a `202 Accepted` response
     similar to the one below:
     ```
     < HTTP/1.1 202 Accepted
     < Content-Length: 0
     < Date: Mon, 12 Aug 2019 19:48:18 GMT
     ```

1.  Exit SSH by typing `exit` into the command prompt.

You have sent two events to the `hello-display` event consumer and two events to
the `goodbye-display` event consumer (note that `say-hello-goodbye` activates
the trigger conditions for _both_ `hello-display` and `goodbye-display`). You
will verify that these events were received correctly in the next section.

## Verifying that events were received

After you send the events, verify that the events were received by the correct subscribers.

1. Look at the logs for the `hello-display` event consumer by entering the
   following command:
   ```
   kubectl --namespace event-example logs -l app=hello-display --tail=100
   ```
   This returns the `Attributes` and `Data` of the events you sent to
   `hello-display`:
   ```
   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
     specversion: 1.0
     type: greeting
     source: not-sendoff
     id: say-hello
     time: 2019-05-20T17:59:43.81718488Z
     contenttype: application/json
   Extensions,
     knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
   Data,
     {
       "msg": "Hello Knative!"
     }
   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
     specversion: 1.0
     type: greeting
     source: sendoff
     id: say-hello-goodbye
     time: 2019-05-20T17:59:54.211866425Z
     contenttype: application/json
   Extensions,
     knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
   Data,
    {
      "msg": "Hello Knative! Goodbye Knative!"
    }
   ```
1. Look at the logs for the `goodbye-display` event consumer by entering the
   following command:
   ```
   kubectl --namespace event-example logs -l app=goodbye-display --tail=100
   ```
   This returns the `Attributes` and `Data` of the events you sent to
   `goodbye-display`:
   ```
   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
      specversion: 1.0
      type: not-greeting
      source: sendoff
      id: say-goodbye
      time: 2019-05-20T17:59:49.044926148Z
      contenttype: application/json
    Extensions,
      knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
   Data,
      {
        "msg": "Goodbye Knative!"
      }
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: greeting
      source: sendoff
      id: say-hello-goodbye
      time: 2019-05-20T17:59:54.211866425Z
      contenttype: application/json
    Extensions,
      knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
    Data,
     {
       "msg": "Hello Knative! Goodbye Knative!"
     }
   ```

## Cleaning up example resources

You can delete the `event-example` namespace and its associated resources from your cluster if you do not plan to use it again in the future.

Delete the `event-example` namespace and all of its resources from your cluster by entering the following command:
```
kubectl delete namespace event-example
```
