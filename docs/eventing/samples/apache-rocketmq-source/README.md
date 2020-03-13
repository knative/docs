---
title: "Apache RocketMQ Source Example"
linkTitle: "Source Example"
weight: 20
type: "docs"
---
Tutorial on how to build and deploy a  [`RocketMQSource`](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-knative/source) using a Knative Serving `Service`.



## Prerequisites

* A Kubernetes cluster
* [Knative Eventing v0.9+](https://knative.dev/docs/install/any-kubernetes-cluster/)
* [Knative Serving v0.9+](https://knative.dev/docs/install/any-kubernetes-cluster/)
* [Apache RocketMQ cluster](http://rocketmq.apache.org/docs/quick-start/)


## Creating a `RocketMQSource` source CRD

1. Install the `rocketmqsource ` sub-component to your Knative cluster:

   ```
   kubectl apply -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/200-serviceaccount.yaml \
                  -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/201-clusterrole.yaml \
                  -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/202-clusterrolebinding.yaml \
                  -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/300-rocketmqsource.yaml \
                  -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/400-controller-service.yaml \
                  -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/500-controller.yaml \
                  -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/600-istioegress.yaml

   ```
2. Check that the `rocketmqsource-controller-manager-0` pod is running.

   ```
   $ kubectl -n knative-sources  get pods
      NAME                                 READY     STATUS    RESTARTS   AGE
      rocketmqsource-controller-manager-0   1/1       Running   0          10s
   ```
3. Check the `rocketmqsource-controller-manager-0` pod logs.


   ```
   $ kubectl -n knative-sources logs rocketmqsource-controller-manager-0
      2020/03/13 04:37:57 Registering Components.
      2020/03/13 04:37:57 Setting up Controller.
      2020/03/13 04:37:57 Adding the RocketMQ Source controller.
      2020/03/13 04:37:57 Starting rocketmqsource controller.
   ```
## Create the event display service

1. Deploy the event display service

   ```
   $ kubectl apply -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/sample/event-display.yaml
      service.serving.knative.dev/event-display created
   ```
1. Ensure that the Service pod is running. The pod name will be prefixed with `event-display`.
 
   ```
   $ kubectl get pods
      NAME                                            READY     STATUS    RESTARTS   AGE
      event-display-6g8pr-deployment-56897dcdfb-vcm82   2/2     Running   0          28s

   ```

## Create Apache RocketMQ Event Source

1. Modify [`apacharocketmqsource.yaml`](https://github.com/apache/rocketmq-externals/blob/master/rocketmq-knative/source/sample/apacherocketmqsource.yaml)accordingly with namesrvAddr,topics,etc.:

   ```yaml
  apiVersion: sources.eventing.knative.dev/v1alpha1
  kind: RocketMQSource
  metadata:
    labels:
      controller-tools.k8s.io: "1.0"
    name: apacherocketmqsource
  spec:
      topic: test
      namesrvAddr: xx.xx.xx.xx:9876 # nameserAddr of RocketMQ Cluster 
      groupName: groupname 
      sink:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: event-display
   ```

2. Deploy the event source.

   ```
   $ kubectl apply -f apacherocketmqsource.yaml
      rocketmqsource.sources.eventing.knative.dev/apacherocketmqsource created
   ```
   
1. Check that the event source pod is running. The pod name will be prefixed with `rocketmq`.

   ```
   $ kubectl get pods
      NAME                                                  READY     STATUS    RESTARTS   AGE
      rocketmq-apacherocketmqsource-p7tdw-67f468884b-n4b9j   1/1       Running   0          4s
   ```
   
1. Ensure the RocketMQ event source started with the necessary
   configuration.
   
   ```
   $ kubectl logs --selector='knative-eventing-source-name=apacherocketmqsource'
    {"level":"info","ts":"2020-03-13T05:55:31.155Z","caller":"receive_adapter/main.go:80","msg":"Starting RocketMQ Receive Adapter. %v","adapter: ":{"K8sClient":{"LegacyPrefix":"/api"},"Namespace":"default","SecretName":"","SecretKey":"","Topic":"test2","NamesrvAddr":"101.200.125.226:9876","RNamespace":"","GroupName":"group2","SubscriptionID":"knative-eventing-default","SinkURI":"http://event-display2.default.svc/","AdCode":""}}
time="2020-03-13T05:55:31Z" level=info msg="the consumer start beginning" consumerGroup=group2 messageModel=Clustering unitMode=false
   ```

## Verify

1. Produce a message with [CLI Admin Tool](http://rocketmq.apache.org/docs/cli-admin-tool/) of Apache RocketMQ:

   ```
   $ sh bin/mqadmin sendMessage -t test2 -k 123 -p "hello" -n 127.0.0.1:9876
      #Broker Name                      #QID  #Send Result            #MsgId
      iZ2ze56wd7v87vxqhdd3j6Z           0     SEND_OK                 7B3945ED000027C170F040CF8EBB0000
   ```
   
1. Check that the RocketMQSource consumed the message and sent it to
   its sink properly.

   ```
   $ kubectl logs --selector='knative-eventing-source-name= apacherocketmqsource'
      subscribe callback: [Message=[topic=test2, body=hello, Flag=0, properties=map[CLUSTER:DefaultCluster CONSUME_START_TIME:1584080251333 KEYS:123 MAX_OFFSET:9 MIN_OFFSET:0 UNIQ_KEY:7B3945ED000027C170F040DD65BE0000 WAIT:true], TransactionId=], MsgId=AC14000100002A9F0000000000028A1E, QueueId=3, StoreSize=185, QueueOffset=8, SysFlag=0, BornTimestamp=1584080251327, BornHost=172.20.0.1:35518, StoreTimestamp=1584080251331, StoreHost=172.20.0.1:10911, CommitLogOffset=166430, BodyCRC=907060870, ReconsumeTimes=0, PreparedTransactionOffset=0]
   ```

1. Ensure the event display received the message.

   ```
   $ kubectl logs --selector='serving.knative.dev/service=event-display2' -c user-container

  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.2
  type: RocketMQEventType
  source: rocketmq
  id: AC14000100002A9F0000000000028C49
  time: 2020-03-13T06:22:08.007642313Z
  contenttype: application/json
Data,
  {
    "Topic": "test2",
    "Body": "aGVsbG8=",
    "Flag": 0,
    "TransactionId": "",
    "Batch": false,
    "Queue": {
      "topic": "",
      "brokerName": "",
      "queueId": 2
    },
    "MsgId": "AC14000100002A9F0000000000028C49",
    "StoreSize": 185,
    "QueueOffset": 12,
    "SysFlag": 0,
    "BornTimestamp": 1584080528001,
    "BornHost": "172.20.0.1:36504",
    "StoreTimestamp": 1584080528006,
    "StoreHost": "172.20.0.1:10911",
    "CommitLogOffset": 166985,
    "BodyCRC": 907060870,
    "ReconsumeTimes": 0,
    "PreparedTransactionOffset": 0
  }
   ```

## Teardown Steps

1. Remove the RocketMQSource

   ```
   $ kubectl delete -f apacherocketmqsource.yaml
      rocketmqsource.sources.eventing.knative.dev "apacherocketmqsource" deleted
   ```
2. Remove the event display

   ```
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/sample/event-display.yam
      service.serving.knative.dev "event-display" deleted
   ```
3. Remove `RocketMQSource` source CRD

   ```
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/300-rocketmqsource.yaml
      customresourcedefinition.apiextensions.k8s.io "rocketmqsources.sources.eventing.knative.dev" deleted
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/400-controller-service.yaml
      service "rocketmq-controller" deleted
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/500-controller.yaml
      statefulset.apps "rocketmqsource-controller-manager" deleted
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/600-istioegress.yaml
     serviceentry.networking.istio.io "rocketmq-ext" deleted
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/202-clusterrolebinding.yaml
     clusterrolebinding.rbac.authorization.k8s.io "eventing-sources-rocketmq-controller" deleted
     clusterrolebinding.rbac.authorization.k8s.io "eventing-sources-rocketmq-resolver" deleted
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/200-serviceaccount.yaml
      serviceaccount "rocketmqsource-controller-manager" deleted
   $ kubectl delete -f https://raw.githubusercontent.com/apache/rocketmq-externals/master/rocketmq-knative/source/config/201-clusterrole.yaml
      clusterrole.rbac.authorization.k8s.io "eventing-sources-rocketmq-controller" deleted
   ```

