# Deploying to Knative using a Private Container Registry
This guide walks you through deploying an application to Knative from source code in a git repository using a private container registry for the container image. The source code should contain a dockerfile. For this guide, we'll use this [simple app](https://github.com/mchmarny/simple-app), but you could use your own.


## Set up a private container registry and obtain credentials.
If you do not want your container image to be publicly available, you may want to use a private container registry. In this example, we'll use IBM Container Registry, but most of these concepts will be similar for other clouds.

1. Ensure you have the [IBM Cloud CLI](https://cloud.ibm.com/docs/cli/reference/ibmcloud/download_cli.html#install_use) installed.  

1. Install the container registry plugin:

```
ibmcloud plugin install container-registry
```

1. Choose a name for your first namespace, and create it. A namespace represents the spot within a registry that holds your images. You can set up multiple namespaces as well as control access to your namespaces by using IAM policies.

```
ibmcloud cr namespace-add <my_namespace>
```

1. Create a token. The automated build processes you'll be setting up will use this token to access your images.

```
ibmcloud cr token-add --description "token description" --non-expiring --readwrite
```

1. The CLI output should include a token identifier and the token. Make note of the token. You can verify that the token was created by listing all tokens.

```
ibmcloud cr token-list
```

# Provide Container Registry Credentials to Knative
You will use the credentials you obtained in the previous section to authenticate to your private container registry. First, you'll need to create a secret to store the credentials for this registry. This secret will be used to push the built image to the container registry.

A Secret is a Kubernetes object containing sensitive data such as a password, a token, or a key. You can also read more about [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/).

1. Create a file named registry-push-secret.yaml containing the following .yaml.

```
apiVersion: v1
kind: Secret
metadata:
  name: basic-user-pass
  annotations:
    build.knative.dev/docker-0: registry.ng.bluemix.net
type: kubernetes.io/basic-auth
stringData:
  username: token
  password: <token_value>
```

1. Update the "password" with your token_value>. Note that username will be the string `token`. Save the file.

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
- name: basic-user-pass
imagePullSecrets:
- name: ibm-cr-secret
```

# Deploy to Knative using the credentials you just set up.
To build our application from the source on github, and push the resulting image to the IBM Container Registry, we will use the Kaniko build template.

1. Install the Kaniko build template
```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml
```