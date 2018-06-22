# Hello World - Node.js

A simple web app in Node that you can use for testing.
It reads in an env variable 'TARGET' and prints "Hello World: ${TARGET}!" if
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this.
* You have installed and initalized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.
* [Node.js](https://nodejs.org/en/) installed and configured.

## Steps to recreate the sample code

1. Create a new directory and initalize npm. You can accept the defaults, but change the entry point to app.js to be consistent with the sample code here.

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

1. Install the `express` dependency:

    ```shell
    npm install express --save
    ```

1. Create a new file named 'app.js' and paste the following code:

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

1. Modify the package.json file to add a start command to the scripts section:

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

1. In your project directory, create a file named `Dockerfile` and paste the following code. For detailed instructions on dockerizing a Node.js app, see [Dockerizing a Node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/).

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

1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google Cloud project. If you are using docker or another container registry instead, replace the entire image path.

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
                image: gcr.io/{PROJECT_ID}/helloworld-nodejs
                env:
                - name: TARGET
                  value: "Node.js Sample v1"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-nodejs
    ```

1. After the build has completed, you can deploy the app into your cluster. Ensure that the container image value in `service.yaml` matches the container you build in the previous step. Apply the configuration using kubectl:

    ```shell
    kubectl apply -f service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use kubectl to list the ingress points in the cluster. You may need to wait a few seconds for the ingress point to be created, if you don't see it right away.

    ```shell
    kubectl get ing --watch

    NAME                        HOSTS                                       ADDRESS        PORTS     AGE
    helloworld-nodejs-ingress   helloworld-nodejs.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-nodejs.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: NOT SPECIFIED
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```