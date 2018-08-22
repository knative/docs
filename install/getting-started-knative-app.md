# Getting Started with Knative App Deployment

This guide shows you how to deploy an app using Knative, then interact with it
using cURL requests.

## Before you begin

You need:
* A Kubernetes cluster with [Knative installed](./README.md).
* An image of the app that you'd like to deploy available on a
  container registry. The image of the sample app used in
  this guide is available on Google Container Registry.

## Sample application

This guides uses the
[Hello World sample app in Go](../serving/samples/helloworld-go) to demonstrate
the basic workflow for deploying an app, but these steps can be adapted for your
own application if you have an image of it available on [Docker Hub](https://docs.docker.com/docker-hub/repos/), [Google Container Registry](https://cloud.google.com/container-registry/docs/pushing-and-pulling), or another container image registry.

The Hello World sample app reads in an `env` variable, `TARGET`, from the
configuration `.yaml` file, then prints "Hello World: ${TARGET}!". If `TARGET`
isn't defined, it will print "NOT SPECIFIED".

## Configuring your deployment

To deploy an app using Knative, you need a configuration `.yaml` file
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
            image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
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
     balancer for your app.
   * Automatically scale your pods up and down based on traffic, including to
     zero active pods.

### Interacting with your app

To see if your app has been deployed succesfully, you need the host URL and
IP address created by Knative.

Note: If your cluster is new, it can take some time before the service is
asssigned an external IP address.

1. To find the IP address for your service, enter:
   
   ```shell
    kubectl get svc knative-ingressgateway -n istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```
    Take note of the `EXTERNAL-IP` address.
   
    You can also export the IP address as a variable with the following command:

    ```shell
    export IP_ADDRESS=$(kubectl get svc knative-ingressgateway -n istio-system -o 'jsonpath={.status.loadBalancer.ingress[0].ip}')

    ```
   > Note: if you use minikube or a baremetal cluster that has no external load balancer, the
     `EXTERNAL-IP` field is shown as `<pending>`. You need to use `NodeIP` and `NodePort` to
     interact your app instead. To get your app's `NodeIP` and `NodePort`, enter the following command:
     ```shell
     export IP_ADDRESS=$(kubectl get node  -o 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc knative-ingressgateway -n istio-system   -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
      ```

1. To find the host URL for your service, enter:

    ```shell
    kubectl get ksvc helloworld-go  -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    NAME                DOMAIN
    helloworld-go       helloworld-go.default.example.com
    ```
    > Note: `ksvc` is an alias for `services.serving.knative.dev`. If you have
      an older version (version 0.1.0) of Knative installed, you'll need to use
      the long name until you upgrade to version 0.1.1 or higher. See
      [Checking Knative Installation Version](../../install/check-install-version.md)
      to learn how to see what version you have installed.

    You can also export the host URL as a variable using the following command:
    
    ```shell
    export HOST_URL=$(kubectl get ksvc helloworld-go  -o jsonpath='{.status.domain}')
    ```

    If you changed the name from `helloworld-go` to something else when creating
    the `.yaml` file, replace `helloworld-go` in the above commands with the
    name you entered.

1. Now you can make a request to your app and see the results. Replace
   `IP_ADDRESS` with the `EXTERNAL-IP` you wrote down, and replace
   `helloworld-go.default.example.com` with the domain returned in the previous
   step.
   
    ```shell
    curl -H "Host: helloworld-go.default.example.com" http://IP_ADDRESS
    Hello World: Go Sample v1!
    ```
   
   If you exported the host URL And IP address as variables in the previous steps, you
   can use those variables to simplify your cURL request:

    ```shell
    curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
    Hello World: Go Sample v1!
    ```
    
    If you deployed your own app, you might want to customize this cURL
    request to interact with your application.

    It can take a few seconds for Knative to scale up your application and return
    a response.

You've succesfully deployed your first application using Knative!

## Cleaning up

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
