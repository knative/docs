# Getting Started with Knative App Deployment

This guide shows you how to deploy an app using Knative Serving.

## Before you begin

You need a Kubernetes cluster with Knative Serving installed.

For installation instructions, see [Installing Knative](./README.md).

You also need an image of the app that you'd like to deploy available on an
image hosting platform like Google Container Registry or Docker Hub. An image of
the sample application used in this guide is available on GCR.

More information about hosting container images:

* [Google Container Registry](https://cloud.google.com/container-registry/docs/pushing-and-pulling)
* [Docker Hub](https://docs.docker.com/docker-hub/repos/)

## Sample application

This guides uses the
[Hello World sample app in Go](../serving/samples/helloworld-go) to demonstrate
the basic workflow for deploying an app, but these steps can be adapted for your
own application if you have an image of it available on Google Container
Registry, Docker Hub, or another container image registry.

The Hello World sample app reads in an `env` variable, `TARGET`, from the
configuration `.yaml` file, then prints "Hello World: ${TARGET}!". If `TARGET`
isn't defined, it will print "NOT SPECIFIED".

## Configuring your deployment

To deploy an app using Knative Serving, you need a configuration .yaml file
that defines a Service. For more information about the Service object, see the
[Resource Types documentation](https://github.com/knative/serving/blob/master/docs/spec/overview.md#service).

This configuration file specifies metadata about the application, points to the
hosted image of the app for deployment, and allows the deployment to be
configured. For more information about what configuration options are available,
see the
[Serving spec documentation](https://github.com/knative/serving/blob/master/docs/spec/spec.md).

Create a new file named `service.yaml`, then copy and paste the following content into it:

```yaml
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-samples/helloworld-go # The URL to the hosted image of the app
            env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Go Sample v1"
```

If you want to deploy the sample app, leave the config file as-is. If you're
deploying an image of your own app, update the name of the app and the URL of
the image accordingly.

## Deploying your app

From the directory where the new `service.yaml` file was created, apply the configuration:
```bash
kubectl apply -f service.yaml
```

Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Perform network programming to create a route, ingress, service, and load
     balance for your app.
   * Automatically scale your pods up and down based on traffic, including to
     zero active pods.

To see if the new app has been deployed succesfully, you need the HOST and
IP_ADDRESS created by Knative.

1. To find the IP address for your service, enter
   `kubectl get svc knative-ingressgateway -n istio-system`. If your cluster is
   new, it can take sometime for the service to get asssigned an external IP address.

    ```shell
    kubectl get svc knative-ingressgateway -n istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```
    Take note of the `EXTERNAL-IP` address.

1. To find the HOST URL for your service, enter:

    ```shell
    kubectl get services.serving.knative.dev helloworld-go  -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    NAME                DOMAIN
    helloworld-go       helloworld-go.default.example.com
    ```
    If you changed the name from `helloworld-go` to something else when creating
    the the `.yaml` file, replace `helloworld-go` in the above command with the
    name you entered.

1. Now you can make a request to your app to see the results. Replace
   `IP_ADDRESS` with the `EXTERNAL-IP` you wrote down, and replace
   `helloworld-go.default.example.com` with the domain returned in the previous
   step.

   > Note, if you use minikube or a baremetal cluster that has no external load balancer,
     `EXTERNAL-IP` field is shown as `<pending>`. You need to use `NodeIP` and `NodePort`:
     ```shell
     export IP_ADDRESS=$(kubectl get node  -o 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc knative-ingressgateway -n istio-system   -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
      ```

   If you deployed your own app, you may want to customize this curl
   request to interact with your application.

    ```shell
    curl -H "Host: helloworld-go.default.example.com" http://IP_ADDRESS
    Hello World: Go Sample v1!
    ```
    It can take a few seconds for Knative to scale up your application and return
    a response.

You've deployed your first application using Knative!

## Cleaning up

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
