---
title: "Workflow as a Function Flow - Automatiko"
linkTitle: "Workflow (Automatiko)"
weight: 1
type: "docs"
---

## Before you begin

You must meet the following requirements to complete this sample:

- A version of the Knative Eventing component installed and running on your
  Kubernetes cluster. Follow the
  [Knative installation instructions](../../../../../docs/install/) if you need to
  create a Knative cluster.
- The following software downloaded and install on your loacal machine:
  - [Java SE 11 or later JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html).  
  - [Docker](https://www.docker.com) for building and pushing your container
    image.
- A [Docker Hub](https://hub.docker.com/) account where you can push your
  container image.

**Tip**: You can clone the [Knative/docs repo](https://github.com/knative/docs)
and then modify the source files. Alternatively, learn more by manually creating
the files yourself.

In case you want to modify the content of the sample recommended is to get - [Automatiko](https://docs.automatiko.io/main/0.0.0/getting-started.html) as well.

## Overview

This is an example showing workflow as a function flow. It implements common scenario for serverless usage where
individual functions build up a complete business case. In this example it is a simple user registration
that performs various checks and registers user in the Swagger PetStore service.

This example illustrates how a workflow is sliced into functions that are composed into a function flow based on
the actual logic steered by the workflow definition. Yet each function can be invoked at anytime making the workflow to
act as a definition that can start at any place and continue according to defined flow of activities aka functions.

See complete description of this example [here](https://docs.automatiko.io/main/0.0.0/examples/userregistration.html)

Workflow as a function flow takes advantage of Knative Eventing as the backbone of the communication to enable

- scalability as each function is invoked via Knative broker
- all data exchange is done with Cloud Events
- flexibility at which point in the workflow definition instance should be started

This example comes with two flavours (depending of what DSL is used to create workflow definition)

- BPMN (Business Process Modeling and Notation) that is a graphical flow chart like diagram
- Serverless Workflow that is json/yaml based definition


### Build the service as container image

Depending which flavour of the example you want to try enter either `automatiko-bpmn` or `automatiko-serverless-workflow` folder.

To build the application issue following maven command

````
mvnw clean package -Pcontainer-native
````

This will build a container with the service that is using native executable built with GraalVM so the build process will take a while but it will be really light and fast at execution.

### Push built container to registry

Once the container image is built push it to external registry that your Knative cluster can pull from.

### Deploy to Knative cluster

Create a Knative eventing broker, for example by using following command:

```
kubectl apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: broker
metadata:
 name: default
 namespace: knative-eventing
EOF
```

Complete deployment file is generated as part of the build and can be found in `target/functions/user-registration-1.0.0.yaml`. To deploy it issue following command:

```
kubectl apply -f target/functions/user-registration-1.0.0.yaml
```

This will provision complete service and all the Knative Eventing triggers. In addition it will also create sink binding to make the service an event source to be able to publish events from function execution.

You can also deploy `cloudevents-player` that will display all events flowing through the broker with following commands


```
kubectl apply -n knative-eventing -f - << EOF
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: cloudevents-player
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "1"
    spec:
      containers:
        - image: quay.io/ruben/cloudevents-player:latest
          env:
            - name: PLAYER_MODE
              value: KNATIVE
            - name: PLAYER_BROKER
              value: default
---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: cloudevents-player
  annotations:
    knative-eventing-injection: enabled
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: cloudevents-player
EOF
```

Get the url of the default broker use following command

```
kubectl get broker default
```

Send request to the broker to start user registration

```
curl -v "http://broker-ingress.knative-eventing.svc.cluster.local/knative-eventing/default" \
-X POST \
-H "Ce-Id: 1234" \
-H "Ce-Specversion: 1.0" \
-H "Ce-Type: io.automatiko.examples.userRegistration" \
-H "Ce-Source: curl" \
-H "Content-Type: application/json" \
-d '{"user" : {"email" : "mike.strong@email.com",  "firstName" : "mike",  "lastName" : "strong"}}'
```

This will go via number of events being exchanged over the Knative broker and invoking functions defined in the workflow. It also uses Swagger Petstore REST api so in case of successful user registration it will be visible in Swagger Petstore as new user.

**NOTE** That Swagger Petstore does not have reliable storage thus it might require few get requests to be issued to see it there.

#### Clean up

To clean up, execute following command

````
kubectl delete -f target/functions/user-registration-1.0.0.yaml
````


### Build the service as container image for Google Cloud Run

To be able to use the same service for Google Cloud Run there are two additional steps required

1. Add dependency to `pom.xml`

````
<dependency>
  <groupId>io.automatiko.extras</groupId>
  <artifactId>automatiko-gcp-pubsub-sink</artifactId>
</dependency>
````

2. Add two properties to `src/main/resources/application.properties` file

````
quarkus.automatiko.target-deployment=gcp-pubsub
quarkus.google.cloud.project-id=CHANGE_ME
````

**NOTE**: Remember to change `CHANGE_ME` to actual project id of your Google Cloud project

Next build the application with following maven command

````
mvnw clean package -Pcontainer-native
````

This will build a container with the service that is using native executable built with GraalVM so the build process will take a while but it will be really light and fast at execution.

### Push built container to Google Cloud Container registry

When container image is built push it to Google Cloud Container registry that Google Cloud Run can pull from.

### Deploy to Google Cloud Run with PubSub

Once the build and push is completed, complete scripts are generated as part of the build and can be found in `target/scripts`. To deploy it, login to Google Cloud Console (or use terminal with `gcloud` installed) where `gcloud` tool can be used and issue all commands from `deploy-user-registration-gcp-cloudrun-1.0.0.txt`

The script content will be similar to following

````
gcloud pubsub topics create io.automatiko.examples.userRegistration.registrationfailed --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.notifyservererror --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.userregistered --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.notifyregistered --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.registeruser --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.invaliddata --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.generateusernameandpassword --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.alreadyregistered --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration.getuser --project=CHANGE_ME
gcloud pubsub topics create io.automatiko.examples.userRegistration --project=CHANGE_ME

gcloud eventarc triggers create notifyservererror --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" --destination-run-service=user-registration-gcp-cloudrun --destination-run-path=/ --transport-topic=io.automatiko.examples.userRegistration.notifyservererror --location=us-central1
gcloud eventarc triggers create notifyregistered --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" --destination-run-service=user-registration-gcp-cloudrun --destination-run-path=/ --transport-topic=io.automatiko.examples.userRegistration.notifyregistered --location=us-central1
gcloud eventarc triggers create registeruser --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" --destination-run-service=user-registration-gcp-cloudrun --destination-run-path=/ --transport-topic=io.automatiko.examples.userRegistration.registeruser --location=us-central1
gcloud eventarc triggers create generateusernameandpassword --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" --destination-run-service=user-registration-gcp-cloudrun --destination-run-path=/ --transport-topic=io.automatiko.examples.userRegistration.generateusernameandpassword --location=us-central1
gcloud eventarc triggers create getuser --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" --destination-run-service=user-registration-gcp-cloudrun --destination-run-path=/ --transport-topic=io.automatiko.examples.userRegistration.getuser --location=us-central1
gcloud eventarc triggers create userregistration --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" --destination-run-service=user-registration-gcp-cloudrun --destination-run-path=/ --transport-topic=io.automatiko.examples.userRegistration --location=us-central1

gcloud run deploy user-registration-gcp-cloudrun --platform=managed --image=gcr.io/CHANGE_ME/user/user-registration-gcp-cloudrun:1.0.0 --region=us-central1
````

Where `CHANGE_ME` will be replaced with the Google Cloud project id configured in `src/main/resources/application.properties` during the build.

This will provision all required components such as

- PubSub Topics
- Eventarc Triggers
- Service deployment

#### Run the service on Google Cloud Run

Once service is deployed you can publish first message (for example using Google Console) to the `io.automatiko.examples.userRegistration` topic
with following content.


```
{"user" : {"email" : "mike.strong@email.com",  "firstName" : "mike",  "lastName" : "strong"}}
```

This will go via number of events being exchanged over the Google Cloud PubSub topics and invoking functions defined in the workflow.


#### Clean up

To clean up, execute all commands from `undeploy-user-registration-gcp-cloudrun-1.0.0.txt` that can be found in `target/scripts`
