# Configuring Probing

## General understanding of Knative Probing

It is important to note that Knative probing is different from Kubernetes probing. 
One reason for this is that Knative tries to minimize cold-start time and thus is probing
in a vastly higher interval than Kubernetes does. 

The general probing architecture looks like this:

![probing-overview](./probes-overview.drawio.svg)

* Users can optionally define Readiness and/or Liveness probes in the `KnativeService` CR.
* The Liveness probes are directly executed by the Kubelet against the according container.
* Readiness probes, on the other hand, are rewritten by Knative to be executed by the Queue-Proxy container to allow more aggressive probing and faster cold-start times.
* Knative will define a default Readiness probe for the primary user container when no probe is defined by the user. It will check for a TCP socket on the traffic port of the Knative Service.
* Knative will also define a Readiness probe for the Queue-Proxy container itself. Queue-Proxy's health endpoint aggregates all results from it's the rewritten Readiness probes for all user containers (primary + sidecars).

Knative will see a Pod as healthy and ready to serve traffic once the Queue-Proxy probe returns a success response and once the Knative networking layer reconfiguration has finished.

!!! note
    Keep in mind, that Knative could see your Pod as healthy and ready while Kubernetes still thinks it is not or vice versa.
    The `Deployment` and `Pod` status do not reflect the status in `Knative`. To fully check the status that Knative sees, you have to check 
    all the conditions on the object hierarchy of Knative (e.g. `Service`, `Configuration`, `Revision`, `PodAutoscaler`, `ServerlessService`, `Route`, `Ingress`).


## Configuring custom probes

!!! note
    If you are using multiple containers in your Knative Service, make sure to enable [multi-container probing](../configuration/feature-flags.md#multiple-container-probing).

You can define Readiness and Liveness probes in your Knative Service the same way you would in Kubernetes:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: runtime
  namespace: default
spec:
  template:
    spec:
      containers:
        
      - name: first-container
        image: <your-image>
        ports:
          - containerPort: 8080
        readinessProbe:
          httpGet:
            port: 8080 # you can also check on a different port than the containerPort (traffic-port)
            path: "/health"
        livenessProbe:
          tcpSocket:
            port: 8080
            
      - name: second-container
        image: <your-image>
        readinessProbe:
          httpGet:
            port: 8089
            path: "/health"
        livenessProbe:
          tcpSocket:
            port: 8089
```

Supported probe types are:

* httpGet
* tcpSocket
* exec
* grpc


!!! note
    Be aware that Knative also does some defaulting and additional validation to make aggressive probing work.

!!! warning
    As the Queue-Proxy container does not rewrite or check defined Liveness probes, it is important to know that Kubernetes can and will restart specific containers once a Liveness probe fails. Make sure to also include the same check that you define as a Liveness probe as a Readiness probe to make sure Knative is aware of the failing container in the Pod. Otherwise, it is possible that you see connection errors during the restart of a container caused by the Liveness probe failure.

