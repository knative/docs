## Installation
> The startup script running on the right will wait for kubernetes to start and knative serving to be installed. (Although Serving is not required for Eventing to work, we install it here for creating consumers succinctly).
> Once you see a prompt, you can click on the commands below at your own pace, and they will be copied and run for you in the terminal on the right.

1. Install Knative Eventing's core components
    ```
    kubectl apply --filename https://github.com/knative/eventing/releases/download/${latest_version}/eventing-crds.yaml
    kubectl apply --filename https://github.com/knative/eventing/releases/download/${latest_version}/eventing-core.yaml
    ```{{execute}}

## Event Driven Architecture
In an event driven architecture, microservice and functions execute business logic when they are triggered by an event.
The source that generates the event is called the "Producer" of the event and the microservice/function is the "consumer".
The microservices/functions in an event-driven architecture are constantly reacting to and producing events themselves.

Producers should send their event data in a specific format, like [Cloud Events](https://cloudevents.io/), to make it easier
for consumers to handle the data. By default, Knative Eventing works with Cloud Events as a standard format for event data.

In the next section we will look at various eventing topologies.