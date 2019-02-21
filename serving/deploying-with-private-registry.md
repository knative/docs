# Deploying to Knative using a private container registry
This guide walks you through deploying an application to Knative from source code in a git repository using a private container registry for the container image. The source code should contain a dockerfile. For this guide, we'll use this [helloworld app](https://github.com/knative/docs/tree/master/serving/samples/helloworld-go), but you could use your own.


## Set up a private container registry and obtain credentials
If you do not want your container image to be publicly available, you may want to use a private container registry. In this example, we'll use IBM Container Registry, but most of these concepts will be similar for other clouds.

1. Ensure you have the [IBM Cloud CLI](https://cloud.ibm.com/docs/cli/reference/ibmcloud/download_cli.html#install_use) installed.  

1. Install the container registry plugin:

    ```
    ibmcloud plugin install container-registry
    ```

1. Choose a name for your first namespace, and then create it: 

    ```
    ibmcloud cr namespace-add <my_namespace>
    ```
    
    A namespace represents the spot within a registry that holds your images. You can set up multiple namespaces as well as control access to your namespaces by using IAM policies.

1. Create a token:

    ```
    ibmcloud cr token-add --description "token description" --non-expiring --readwrite
    ```
    
    The automated build processes you'll be setting up will use this token to access your images.

1. The CLI output should include a token identifier and the token. Make note of the token. You can verify that the token was created by listing all tokens:

    ```
    ibmcloud cr token-list
    ```

## Provide container registry credentials to Knative
You will use the credentials you obtained in the previous section to authenticate to your private container registry. First, you'll need to create a secret to store the credentials for this registry. This secret will be used to push the built image to the container registry.

A Secret is a Kubernetes object containing sensitive data such as a password, a token, or a key. You can also read more about [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).

1. Create a file named `registry-push-secret.yaml` containing the following:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: registry-push-secret
      annotations:
        build.knative.dev/docker-0: https://registry.ng.bluemix.net
    type: kubernetes.io/basic-auth
    stringData:
      username: token
      password: <token_value>
    ```

1. Update the "password" with your <token_value>. Note that username will be the string `token`. Save the file.

1. Apply the secret to your cluster.

    ```
    kubectl apply --filename registry-push-secret.yaml
    ```

1. You will also need a secret for the knative-serving component to pull down an image from the private container registry. This secret will be a `docker-registry` type secret. You can create this via the commandline. For username, simply use the string `token`. For <token_value>, use the token you made note of earlier.

    ```
    kubectl create secret docker-registry ibm-cr-secret --docker-server=https://registry.ng.bluemix.net --docker-username=token --docker-password=<token_value>
    ```

A Service Account provides an identity for processes that run in a Pod. This Service Account will be used to link the build process for Knative to the Secrets you just created.

1. Create a file named service-account.yaml containing the following .yaml.

    ```
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: build-bot
    secrets:
    - name: registry-push-secret
    imagePullSecrets:
    - name: ibm-cr-secret
    ```

1. Apply the service account to your cluster:

    ```
    kubectl apply -f service-account.yaml
    ```

## Deploy to Knative
To build our application from the source on GitHub, and push the resulting image to the IBM Container Registry, we will use the Kaniko build template.

1. Install the Kaniko build template

    ```
    kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml
    ```

1. You need to create a service manifest which defines the service to deploy, including where the source code is and which build-template to use. Create a file named `service.yaml` and copy the following definition. Make sure to replace {NAMESPACE} with your own namespace you created earlier:

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      runLatest:
        configuration:
          build:
            apiVersion: build.knative.dev/v1alpha1
            kind: Build
            spec:
              serviceAccountName: build-bot
              source:
                git:
                  url: https://github.com/knative/docs
                  revision: master
                subPath: serving/samples/helloworld-go
              template:
                name: kaniko
                arguments:
                - name: IMAGE
                  value: registry.ng.bluemix.net/{NAMESPACE}/helloworld-go:latest
          revisionTemplate:
            spec:
              serviceAccountName: build-bot
              container:
                image: registry.ng.bluemix.net/{NAMESPACE}/helloworld-go:latest 
                imagePullPolicy: Always
                env:
                  - name: TARGET
                    value: "Go Sample v1"
    ```

1. Apply the configuration using `kubectl`:
    
    ```
    kubectl apply -f service.yaml
    ```

    Applying this service definition will kick off a series of events:
    - Fetches the revision specified from GitHub and builds it into a container, using the Kaniko build template.
    - Pushes the latest image to the private registry using the registry-push-secret
    - Pulls down the latest image from the private registry using the ibm-cr-secret.
    - Starts the service, and your app will be live.


1. You can run `kubectl get pods --watch` to see the pods initializing.

1. Once all the pods are initialized, you can see that your container image was built and pushed to the IBM Container Registry:

    ```
    ibmcloud cr image-list
    ```

## Test Application Behavior
1. Run the following command to find the external IP address for your service:

   ```shell
   INGRESSGATEWAY=istio-ingressgateway
   kubectl get svc $INGRESSGATEWAY --namespace istio-system
   ```

   Example:

   ```shell
   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d
   ```

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc helloworld-go  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   ```

   Example:

   ```shell
   NAME                DOMAIN
   helloworld-go       helloworld-go.default.example.com
   ```

1. Test your app by sending it a request. Use the following `curl` command with
   the domain URL `helloworld-go.default.example.com` and `EXTERNAL-IP` address
   that you retrieved in the previous steps:

   ```shell
   curl -H "Host: helloworld-go.default.example.com" http://{EXTERNAL_IP_ADDRESS}
   ```

   Example:

   ```shell
   curl -H "Host: helloworld-go.default.example.com" http://35.203.155.229
   Hello Go Sample v1!
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
