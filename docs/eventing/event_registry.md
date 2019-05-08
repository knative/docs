# Event Registry


## Before you begin


## Using the Registry

 
## Problem 

As an `Event Consumer` I want to be able to discover the different event types that I can consume 
from the different Brokers. 
This is also known as the `discoverability` use case, and is the main focus of this proposal. 

## Objective

Design an **initial** version of the **Registry** for the **MVP** that can support discoverability of 
the different event types that can be consumed from the eventing mesh. For details on the different user stories 
that this proposal touches, please refer to the 
[User stories and personas for Knative eventing](https://docs.google.com/document/d/15uhyqQvaomxRX2u8s0i6CNhA86BQTNztkdsLUnPmvv4/edit?usp=sharing) document.
Note that this proposal targets the cases where the Broker/Trigger model is used.

#### Out of scope

- Registry to Registry communication. This doesn't seem needed for an MVP.
- Security-related matters. Those are handled offline by the `Cluster Configurator`, e.g., the `Cluster Configurator` 
takes care of setting up Secrets for connecting to a GitHub repo, and so on.
- Registry synchronization with `Event Producers`. We assume that if new GitHub events are created by 
GitHub after our cluster has been configured (i.e., our GitHub CRD Source installed) and the appropriate webhooks 
have been created, we will need to create new webhooks (and update the GitHub CRD Source) if we want to listen for 
those new events. Until doing so, those new events shouldn't be listed in the Registry. 
Such task will again be in charge of the `Cluster Configurator`.

## Requirements

Our design revolves around the following core requirements:

1. We should have a Registry per namespace to enforce isolation.
2. The Registry should contain the event types that can be consumed from
the eventing mesh in order to support the `discoverability` use case.
If an event type is not ready for consumption, we should explicitly indicate so (e.g., if the Broker 
is not ready).
3. The event types stored in the Registry should contain (all) the required information 
for a consumer to create a Trigger without resorting to some other OOB mechanism.


## Design Ideas

### EventType CRD

We propose introducing a namespaced-EventType Custom Resource Definition (CRD). 
Here is an example of how a **Custom Object** (CO) would look like:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventType
metadata:
  name: com.github.pullrequest
  namespace: default
spec:
  type: com.github.pull_request
  source: https://github.com/user/repo
  schema: https://github.com/schemas/pull_request
  description: "GitHub pull request"
  broker: default
```

- The `name` of the EventType is advisory, non-authoritative. Given that CloudEvents types can 
contain characters that may not comply with Kubernetes naming conventions, we will (slightly) 
modify those names to make them K8s-compliant, whenever we need to generate them. 

- `type`: is authoritative. This refers to the CloudEvent type as it enters into the eventing mesh. 

- `source`: is a valid URI. Refers to the CloudEvent source as it enters into the eventing mesh.

- `schema`: is a URI with the EventType schema. It may be a JSON schema, a protobuf schema, etc. It is optional.

- `description`: is a string describing what the EventType is about. It is optional.

- `broker` refers to the Broker that can provide the EventType. 

In order to *uniquely* identify an EventType, we would need to look at the tuple `(type, source, schema, broker)`, 
as there might be EventTypes with the same `type` but different `sources`, or pointing to different `brokers`, and so on. 

### Typical Flow

1. A `Cluster Configurator` configures the cluster in a way that allows the population of EventTypes in the Registry. 
We foresee the following two ways of populating the Registry for the MVP:

    1.1. Event Source CO instantiation

    Upon instantiation of an Event Source CO by a `Cluster Configurator`, the Source will register its EventTypes.

    Example:
    
    ```yaml
    apiVersion: sources.eventing.knative.dev/v1alpha1
    kind: GitHubSource
    metadata:
      name: github-source-sample
      namespace: default
    spec:
      eventTypes:
        - push
        - pull_request
      ownerAndRepository: my-other-user/my-other-repo
      accessToken:
        secretKeyRef:
          name: github-secret
          key: accessToken
      secretToken:
        secretKeyRef:
          name: github-secret
          key: secretToken
      sink:
        apiVersion: eventing.knative.dev/v1alpha1
        kind: Broker
        name: default
    ```
 
    By applying the above file, two EventTypes will be registered, with types `dev.knative.source.github.push` and 
    `dev.knative.source.github.pull_request`, source `https://github.com/my-other-user/my-other-repo`, for the `default` Broker in the `default`
     namespace, and with owner `github-source-sample`. This should be done by the Event Source controller, in this case, 
     the GitHubSource controller. Although not shown here, the controller could add some `description` to the EventTypes, e.g., 
     from which owner and repo the events are, etc.
     
    Note that the `Cluster Configurator` is the person in charge of taking care of authentication-related matters. E.g., if a new `Event Consumer` 
    wants to listen for events from a different GitHub repo, the `Cluster Configurator` will take care of the necessary secrets generation, 
    and new Source instantiation.
     
    In YAML, the above EventTypes would look something like these:
    
    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: EventType
    metadata:
      generateName: dev.knative.source.github.push-
      namespace: default
      owner: # Owned by github-source-sample
    spec:
      type: dev.knative.source.github.push
      source: https://github.com/my-other-user/my-other-repo
      broker: default
   ---
    apiVersion: eventing.knative.dev/v1alpha1
    kind: EventType
    metadata:
      generateName: dev.knative.source.github.pullrequest-
      namespace: default
      owner: # Owned by github-source-sample
    spec:
      type: dev.knative.source.github.pull_request
      source: https://github.com/my-other-user/my-other-repo
      broker: default
    ```
    
    Two things to notice: 
    - We generate the names by stripping invalid characters from the original type (e.g., `_`). By generating names we aim to 
    avoid naming collisions. This is a **separate discussion** on whether we should generate them when code (in this case, 
    the GitHubSource controller) creates the EventTypes or not. 
     
    - We add the prefix `dev.knative.source.github.` to `spec.type`. This is a **separate discussion** on whether we should 
    change the (GitHub) web hook types or not.
 
    1.2. Manual Registration

    The `Cluster Configurator` manually `kubectl applies` an EventType CR.
    
    Example: 
    
    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: EventType
    metadata:
      name: org.bitbucket.repofork
      namespace: default
    spec:
      type: org.bitbucket.repo:fork
      source: https://bitbucket.org/my-other-user/my-other-repo
      broker: dev
      description: "BitBucket fork"
    ``` 

    This would register the EventType named `org.bitbucket.repofork` with type `org.bitbucket.repo:fork`, 
    source `https://bitbucket.org/my-other-user/my-other-repo` in the `dev` Broker of the `default` namespace.
    
    As under the hood, `kubectl apply` just makes a REST call to the API server with the appropriate RBAC permissions, 
    the `Cluster Configurator` can give EventType `create` permissions to trusted parties, so that they can register 
    their EventTypes.  

1. An `Event Consumer` checks the Registry to see what EventTypes it can consume from the mesh.

    Example:
    
    `$ kubectl get eventtypes -n default`
    
    ```
    NAME                                         TYPE                                    SOURCE                                              SCHEMA                                     BROKER     DESCRIPTION           READY    REASON
    org.bitbucket.repofork                       org.bitbucket.repo:fork                 https://bitbucket.org/my-other-user/my-other-repo                                              dev        BitBucket fork        False    BrokerIsNotReady
    com.github.pullrequest                       com.github.pull_request                 https://github.com/user/repo                        https://github.com/schemas/pull_request    default    GitHub pull request   True 
    dev.knative.source.github.push-34cnb         dev.knative.source.github.push          https://github.com/my-other-user/my-other-repo                                                 default                          True 
    dev.knative.source.github.pullrequest-86jhv  dev.knative.source.github.pull_request  https://github.com/my-other-user/my-other-repo                                                 default                          True  
    ```

1. The `Event Consumer` creates a Trigger to listen to an EventType in the Registry. 

    Example:
    
    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Trigger
    metadata:
      name: my-service-trigger
      namespace: default
    spec:
      filter:
        sourceAndType:
          type: dev.knative.source.github.push
          source: https://github.com/my-other-user/my-other-repo
      subscriber:
        ref:
         apiVersion: serving.knative.dev/v1alpha1
         kind: Service
         name: my-service
    ```

## FAQ

Here is a list of frequently asked questions that may help clarify the scope of the Registry.

- Is the Registry meant to be used just for creating Triggers or for also setting up Event Sources?

    It's mainly intended for helping the `Event Consumer` with the `discoverability` use case. Therefore, 
    it is meant for helping out creating Triggers.

- If I have a simple use case where I'm just setting up an Event Source and my KnService is its Sink (i.e., no Triggers involved), 
is there a need/use for the Registry?

    As stated before, this Registry proposal for the MVP helps creating Triggers, i.e., when you use the Broker/Trigger 
    model. As you can see in the EventType CRD, there is a mandatory `broker` field. If you are not sending events to a Broker, 
    then EventTypes won't be added to the Registry (at least in this proposal). 
    Implementation-wise, we can check whether the Source's sink kind is `Broker`, and if so, then register its EventTypes.
    
- Is the Registry meant to be used in a single-user environment where the same person is setting up both the Event Source and 
the destination Sink?

    We believe is mainly intended for multi-user environment. A `Cluster Configurator` persona is in charge of setting up 
    the Sources, and `Event Consumers` are the ones that create the Triggers. Having said that, it can also be used in 
    a single-user environment, but the Registry might not add much value compared to what we have right now in terms of 
    `discoverability`, but it surely does in terms of, for example, `admission control`. 
    
- Does a user need to know which type of environment they're in before they should know if they should look at the Registry? 
In other words, is a Registry always going to be there and if not under what conditions will it be?

    A Registry will always be there, i.e., `Event Consumers` will always be able to `kubectl get eventtypes -n <namespace>`. 
    In case no CO Sources are pointing to Brokers, then the Registry will be empty. 
    
- Once an Event Source is created, how is a new one created with different auth in an env where the user is really just meant 
to deal with Triggers? This may not be a Registry specific question but if one of the goals of the Registry is to make it 
so that the user only deals with Triggers using the info in the Registry, I think this aspect comes into play.

    We believe the Event Source instantiation with different credentials should be handled by the `Cluster Configurer`. If the 
    `Cluster Configurer` persona happens to be the same person as the `Event Consumer` persona, then it will have to take care 
    of creating the Source. This is related to the question of a single-user, multi-user environment above.
    
- I've heard conflicting messages around whether the Registry is just a list of Event Types or it will also be a list of 
Event Sources so that the user doesn't need to query the CRDs to get the list. We need to be clear about this.

    The Registry is a list of EventTypes. Having said that, the `Event Consumer` could also (if it has the proper RBAC permissions) 
    list Event Sources (e.g., `kubectl get crds -l eventing.knative.dev/source=true`), but that list is not part of what we call 
    Registry here. The idea behind the fields in the EventType CRD is to have all the necessary information there in 
    order to create Triggers, thus, in most cases, the `Event Consumer` shouldn't have to list Sources. 

-  I wonder if the Event Source populating the Registry should happen when the Event Source is loaded into the system, 
meaning when the Event Source's CRD is installed (not when an instance of the CRD is created). 

    The problem with that is that you don't have a namespace (nor Broker, user/repo, etc.) at that point. 
    Which namespace the EventType should be created on? Pointing to which Broker? 
    Implementation-wise, one potential solution is to have a controller for source CRDs, whenever one is installed, search for all the namespaces with 
    eventing enabled (`kubectl get namespaces -l knative-eventing-injection=enabled`), and adding all the possible EventTypes from that CRD to each of 
    the Brokers in those namespaces. A downside of this is that the Registry information is not "accurate", in the sense that it only has info about EventTypes 
    that may potentially flow in the system. But actually, they will only be able to flow when a CO is created.

- How can I filter events by the CloudEvents `subject` field?

  The EventType CRD will not include a `subject` field because we expect the cardinality of `subject` to be quite high. 
  However, a user that would like to filter by a known subject value can do this in the Trigger with the 
  Advanced Filtering proposed in [#1047](https://github.com/knative/eventing/pull/1047).
  
  Example:

  ```yaml
  apiVersion: eventing.knative.dev/v1alpha1
  kind: Trigger
  metadata:
    name: only-knative
  spec:
    filter:
     cel:
        expression: ce.subject.match("/knative/*")
    subscriber:
     ref:
       apiVersion: serving.knative.dev/v1alpha1
       kind: Service
       name: knative-events-processor
  ```

