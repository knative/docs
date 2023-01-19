# Hello World - Node.js

A simple web app written in Node.js that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified, it will use "World" as the TARGET.

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-nodejs
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- [Node.js](https://nodejs.org/en/) installed and configured.

## Recreating the sample code

1. Create a new directory and initialize `npm`:

   ```bash
   npm init

   package name: (helloworld-nodejs)
   version: (1.0.0)
   description:
   entry point: (index.js)
   test command:
   git repository:
   keywords:
   author:
   license: (ISC) Apache-2.0
   ```

1. Install the `express` package:

   ```bash
   npm install express
   ```

1. Create a new file named `index.js` and paste the following code:

   ```js
   const express = require('express');
   const app = express();

   app.get('/', (req, res) => {
     console.log('Hello world received a request.');

     const target = process.env.TARGET || 'World';
     res.send(`Hello ${target}!\n`);
   });

   const port = process.env.PORT || 8080;
   app.listen(port, () => {
     console.log('Hello world listening on port', port);
   });
   ```

1. Modify the `package.json` file to add a start command to the scripts section:

   ```json
   {
     "name": "knative-serving-helloworld",
     "version": "1.0.0",
     "description": "Simple hello world sample in Node",
     "main": "index.js",
     "scripts": {
       "start": "node index.js"
     },
     "author": "",
     "license": "Apache-2.0",
     "dependencies": {
       "express": "^4.18.2"
     }
   }
   ```

1. In your project directory, create a file named `Dockerfile` and copy the following code
   block into it. For detailed instructions on dockerizing a Node.js app,
   see
   [Dockerizing a Node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/).

   ```Dockerfile
   # Use the official lightweight Node.js 12 image.
   # https://hub.docker.com/_/node
   FROM node:12-slim

   # Create and change to the app directory.
   WORKDIR /usr/src/app

   # Copy application dependency manifests to the container image.
   # A wildcard is used to ensure both package.json AND package-lock.json are copied.
   # Copying this separately prevents re-running npm install on every code change.
   COPY package*.json ./

   # Install production dependencies.
   RUN npm install --only=production

   # Copy local code to the container image.
   COPY . ./

   # Run the web service on container startup.
   CMD [ "npm", "start" ]
   ```

1. Create a `.dockerignore` file to ensure that any files related to a local
   build do not affect the container that you build for deployment.

   ```ignore
   Dockerfile
   README.md
   node_modules
   npm-debug.log
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-nodejs
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-nodejs
             env:
               - name: TARGET
                 value: "Node.js Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-nodejs .

   # Push the container to docker registry
   docker push {username}/helloworld-nodejs
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-nodejs  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-nodejs   http://helloworld-nodejs.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   ```bash
   curl http://helloworld-nodejs.default.1.2.3.4.sslip.io
   Hello Node.js Sample v1!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
