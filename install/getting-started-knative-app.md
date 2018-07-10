# Getting Started with Knative App Deployment

This guide shows you how to deploy an app using Knative Serving.

## Before you begin

You'll need a Kubernetes cluster with Knative Serving installed.

For installation instructions, see one of the following install guides:
* [Easy Install on Google Kubernetes Engine](Knative-with-GKE.md)
* [Easy Install on Minikube](Knative-with-Minikube.md)

You'll also need an image of the app you'd like to deploy available on a
image hosting platform like Google Container Registry or Docker Hub. An image of
the sample applicatio used in this guide is available on GCR.

## Sample application

For this guide, we'll work with the
[Hello World sample app in Go](../serving/samples/helloworld-go) to demonstrate
the basic workflow for deploying an app, but these steps can be adapted for your
own application if you have an image of it available.

The Hello World sample app reads in an `env` variable, `TARGET`, from the
configuration `.yaml` file, then prints "Hello World: ${TARGET}!". If TARGET is
not specified, it will print "NOT SPECIFIED" as the TARGET.

## Configuring your deployment

To deploy an app using Knative Serving, we need a configuration .yaml file that
defines a Service. For more information about the Service object, see the
[Resource Types documentation](https://github.com/knative/serving/blob/master/docs/spec/overview.md#service).

This configuration file specifies metadata about our app, points to the hosted
image of the app for deployment, and allows us to configure our deployment. For
more information about what configuration options are available, see the
[Serving spec documentation](https://github.com/knative/serving/blob/master/docs/spec/spec.md).

Create a new file and name it `service.yaml`, then copy and paste the following:

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
deploying and image of your own app, update the name of the app and the link to
the image accordingly.

## Deploying your app

From the directory where you the new `service.yaml` file was created, apply the configuration:
```bash
kubectl apply -f service.yaml
```

Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

To see if our new app has been deployed succesfully, we'll need the HOST and IP_ADDRESS created by Knative.

1. To find the IP address for your service, enter
   `kubectl get svc knative-ingressgateway -n istio-system` to get the ingress IP for your
   cluster. If your cluster is new, it may take sometime for the service to get asssigned
   an external IP address.

    ```shell
    kubectl get svc knative-ingressgateway -n istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```
1. To find the URL for your service, enter:
    ```
    kubectl get services.serving.knative.dev helloworld-go  -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    NAME                DOMAIN
    helloworld-go       helloworld-go.default.example.com
    ```

1. Now you can make a request to your app to see the results. Replace
   `IP_ADDRESS` with the address you see returned in the previous step. If you
   deployed your own app, you may want to customize this curl request.

    ```shell
    curl -H "Host: helloworld-go.default.example.com" http://IP_ADDRESS
    Hello World: Go Sample v1!
    ```

You've deployed your first application using Knative.

## Cleaning up

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```