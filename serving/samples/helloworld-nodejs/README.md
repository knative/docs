# Hello World - Node.js sample

A simple web app written in Node.js that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello World: ${TARGET}!". If
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/install/) if you need
  to create one.
* [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
* [Node.js](https://nodejs.org/en/) installed and configured.

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new directory and initalize `npm`. You can accept the defaults,
   but change the entry point to `app.js` to be consistent with the sample
   code here.

    ```shell
    npm init

    package name: (helloworld-nodejs)
    version: (1.0.0)
    description:
    entry point: (index.js) app.js
    test command:
    git repository:
    keywords:
    author:
    license: (ISC) Apache-2.0
    ```

1. Install the `express` package:

    ```shell
    npm install express --save
    ```

1. Create a new file named `app.js` and paste the following code:

    ```js
    const express = require('express');
    const app = express();

    app.get('/', function (req, res) {
      console.log('Hello world received a request.');

      var target = process.env.TARGET || 'NOT SPECIFIED';
      res.send('Hello world: ' + target);
    });

    var port = 8080;
    app.listen(port, function () {
      console.log('Hello world listening on port',  port);
    });
    ```

1. Modify the `package.json` file to add a start command to the scripts section:

    ```json
    {
      "name": "knative-serving-helloworld",
      "version": "1.0.0",
      "description": "",
      "main": "app.js",
      "scripts": {
        "start": "node app.js",
        "test": "echo \"Error: no test specified\" && exit 1"
      },
      "author": "",
      "license": "Apache-2.0"
    }
    ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Node.js app,
   see [Dockerizing a Node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/).

    ```docker
    FROM node:8

    # Create app directory
    WORKDIR /usr/src/app

    # Install app dependencies
    # A wildcard is used to ensure both package.json AND package-lock.json are copied
    # where available (npm@5+)
    COPY package*.json ./

    RUN npm install
    # If you are building your code for production
    # RUN npm install --only=production

    # Bundle app source
    COPY . .

    EXPOSE 8080
    CMD [ "npm", "start" ]
    ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub username.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-nodejs
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: docker.io/{username}/helloworld-nodejs
                env:
                - name: TARGET
                  value: "Node.js Sample v1"
    ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your
   Docker Hub username:

    ```shell
    # Build the container on your local machine
    docker build -t {username}/helloworld-nodejs .

    # Push the container to docker registry
    docker push {username}/helloworld-nodejs
    ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in
   the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply -f service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use
   `kubectl get svc knative-ingressgateway -n istio-system` to get the ingress IP for your
   cluster. If your cluster is new, it may take sometime for the service to get asssigned
   an external IP address.

    ```shell
    kubectl get svc knative-ingressgateway -n istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```

1. Now you can make a request to your app to see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-nodejs.default.example.com" http://{IP_ADDRESS}
    Hello World: NOT SPECIFIED
    ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
