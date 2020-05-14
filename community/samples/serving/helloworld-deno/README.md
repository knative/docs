A simple web app written in Deno.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-deno
```

## Before you begin

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../../docs/install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new file named `deps.ts` and paste the following script:

   ```ts
   export { serve } from "https://deno.land/std@std@0.50.0/http/server.ts";
   ```

1. Create a new file named `main.ts` and paste the following script:

   ```ts
   import { serve } from "./deps.ts";
   import "https://deno.land/x/dotenv/mod.ts";

   const PORT = Deno.env.get('PORT') || 8080;
   const s = serve(`0.0.0.0:${PORT}`);
   const body = new TextEncoder().encode("Hello Deno\n");

   console.log(`Server started on port ${PORT}`);
   for await (const req of s) {
     req.respond({ body });
   }
   ```

1. Create a new file named `Dockerfile` and copy the code block below into it.

   ```docker
   FROM hayd/alpine-deno:1.0.0-rc2
   WORKDIR /app

   # These steps will be re-run upon each file change in your working directory:
   COPY . ./

   # Added to ENTRYPOINT of base image.
   CMD ["run", "--allow-env", "--allow-net", "main.ts"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-deno
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-deno
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-deno .

   # Push the container to docker registry
   docker push {username}/helloworld-deno
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative performs the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc helloworld-deno  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME                URL
   helloworld-deno        http://helloworld-deno.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-deno.default.1.2.3.4.xip.io
   ```

   Example:

   ```shell
   curl http://helloworld-deno.default.1.2.3.4.xip.io
   [1] "Hello R Sample v1!"
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
