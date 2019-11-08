---
title: "Using Knative Services"
weight: 01
linkTitle: "Using Knative Services"
type: "docs"
---

Knative services are used to deploy an application. Knative Services attempt to model a more logical definition of a Service or Application. To achieve this, Services use the concept of Revisions which are each backed by a deployment with 2 Kubernetes Services.   

For more information about Kubernetes Services, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/service/).   

Each Knative Service is defined by a Route and a Configuration, which have the same name as the Service, contained in a YAML file.

## Before you begin

To use Knative Services, you will need:
* A Kubernetes cluster with [Knative installed](https://knative.dev/docs/install/index.html).

## Creating a Knative Service
To create an application, you need to create a YAML file that defines a Knative Service.
This YAML file specifies metadata about the application, points to the hosted image of the app and allows the Service to be configured.

This guide uses the [Hello World sample app in Go](https://knative.dev/docs/serving/samples/hello-world/helloworld-go) to demonstrate the structure of a Service YAML file and the basic workflow for deploying an app. These steps can be adapted for your own application if you have an image of it available on Docker Hub, Google Container Registry, or another container image registry.

The Hello World sample app does the following:
1. Reads an environment variable, `TARGET`, from the configuration .yaml file
1. Prints `Hello World: \${TARGET}!`. If `TARGET` is not defined, it will print `NOT SPECIFIED`.

### Procedure

1. Create a new file named `service.yaml` containing the following information.

```yml
apiVersion: serving.knative.dev/v1 # (1)
kind: Service
metadata:
 name: helloworld-go # (2)
 namespace: default # (3)
spec:
 template:
  spec:
   containers:
    - image: gcr.io/knative-samples/helloworld-go # (4)
     env:
      - name: TARGET # (5)
       value: "Go Sample v1"
```
**(1)** Current version of Knative   
**(2)** The name of the app   
**(3)** The namespace the app will use   
**(4)** The URL to the image of the app   
**(5)** The environment variable printed out by the sample app

> Note: If you’re deploying an image of your own app, update the name of the app and the URL of the image accordingly.

## Creating a private cluster-local Service
By default services deployed through Knative are published to an external IP
address, making them public services on a public IP address and with a
[public URL](./using-a-custom-domain.md).

While this is useful for services that need to be accessible from outside of the
cluster, frequently you may be building a backend service which should not be
available off-cluster.

Knative provides two ways to enable private services which are only available
inside the cluster:

1. To make all services only available only from within the cluster, change the default domain to
   `svc.cluster.local` by
   [editing the `config-domain` config map](./using-a-custom-domain.md). This
   will change all services deployed through Knative to only be published to the
   cluster, none will be available off-cluster.
1. To make an individual service cluster-local, the service or route can be
   labeled in such a way to prevent it from getting published to the external
   gateway.

### Label a service to be cluster-local

To configure a Service to only be available on the cluster-local network (and
not on the public Internet), you can apply the
`serving.knative.dev/visibility=cluster-local` label to the Service object.

To label the Service:

```shell
kubectl label kservice ${KSVC_NAME} serving.knative.dev/visibility=cluster-local
```

To label a route:

```shell
kubectl label route ${ROUTE_NAME} serving.knative.dev/visibility=cluster-local
```

For example, you can deploy the [Hello World sample](./samples/helloworld-go)
and then convert it to be an cluster-local service by labeling the service:

```shell
kubectl label kservice helloworld-go serving.knative.dev/visibility=cluster-local
```

You can then verify that the change has been made by verifying the URL for the
helloworld-go service:

```shell
kubectl get ksvc helloworld-go

NAME            URL                                              LATESTCREATED         LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.svc.cluster.local   helloworld-go-2bz5l   helloworld-go-2bz5l   True
```

The service returns the a URL with the `svc.cluster.local` domain, indicating
the service is only available in the cluster local network.

## Deploying an application using Knative Services

To deploy an application, you must apply the `service.yaml` file.

### Procedure
1. Navigate to the directory where the `service.yaml` file is contained.
2. Deploy the application by applying the `service.yaml` file.   
  ```
  kubectl apply --filename service.yaml
  ```

Now that service has been created and the application has been deployed, Knative will create a new immutable revision for this version of the application.   

Knative will also perform network programming to create a route, ingress, service, and load balancer for your application, and will automatically scale your pods up and down based on traffic, including inactive pods.

## Interacting with your app

To see if your application has been deployed successfully, you need the host URL and IP
address created by Knative.

> Note: If your cluster is new, it can take some time before the Service is
assigned an external IP address.

1. To find the IP address for your Service, enter:

   ```shell
   INGRESSGATEWAY=knative-ingressgateway
   if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
   fi

   kubectl get svc $INGRESSGATEWAY --namespace istio-system
   ```

The command will return something similar to this:

```shell
   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   istio-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
````

Take note of the `EXTERNAL-IP` address.

You can also export the IP address as a variable with the following command:

```shell
   export IP_ADDRESS=$(kubectl get svc $INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
```

> Note: If you use minikube or a baremetal cluster that has no external load
> balancer, the `EXTERNAL-IP` field is shown as `<pending>`. You need to use
> `NodeIP` and `NodePort` to interact your app instead. To get your app's
> `NodeIP` and `NodePort`, enter the following command:

```shell
   export IP_ADDRESS=$(kubectl get node  --output 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

1. To find the host URL for your service, enter:

   ```shell
   kubectl get route helloworld-go  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   The command will return the following:

   ```shell
   NAME                URL
   helloworld-go       http://helloworld-go.default.example.com
   ```

   > Note: By default, Knative uses the `example.com` domain. To configure a
   > custom DNS domain, see
   > [Using a Custom Domain](../serving/using-a-custom-domain.md).

   If you changed the name from `helloworld-go` to something else when creating
   the `.yaml` file, replace `helloworld-go` in the above commands with the name
   you entered.

1. Now you can make a request to your app and see the results. Replace
   `IP_ADDRESS` with the `EXTERNAL-IP` you wrote down, and replace
   `helloworld-go.default.example.com` with the domain returned in the previous
   step.

   ```shell
   curl -H "Host: helloworld-go.default.example.com" http://${IP_ADDRESS}
   Hello World: Go Sample v1!
   ```
  > Note: If you have configured a domain associated with your IP address, you do not need to inject the host header in this step.

   If you deployed your own app, you might want to customize this cURL request
   to interact with your application.

   It can take a few seconds for Knative to scale up your application and return
   a response.

   > Note: Add `-v` option to get more detail if the `curl` command failed.

You've successfully deployed your first application using Knative!

## Cleaning up

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```

## Modifying Knative Services
Any changes to specifications, metadata labels or metadata annotations for a Service must be copied to the Route and Configuration owned by that Service.   

In addition, the `serving.knative.dev/service` label on the Route and Configuration must be set to the name of the Service. Any additional labels or annotations on the Route and Configuration not specified above must be removed.   

The Service updates its `status` fields based on the corresponding `status` value for the owned Route and Configuration.
The Service must include conditions of`RoutesReady` and `ConfigurationsReady` in addition to the generic `Ready` condition. Other conditions can also be present.

## Additional resources
* For more information about the Knative Service object, see the [Resource Types documentation](https://github.com/knative/serving/blob/master/docs/spec/overview.md#service).
