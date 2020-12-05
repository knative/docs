A simple web app written in Clojure that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified, it will use "World" as the TARGET.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../docs/install/README.md) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new file named `src/helloworld/core.clj` and paste the following
   code. This code creates a basic web server which listens on port 8080:

   ```clojure
   (ns helloworld.core
     (:use ring.adapter.jetty)
     (:gen-class))

   (defn handler [request]
     {:status 200
      :headers {"Content-Type" "text/html"}
      :body (str "Hello "
                 (if-let [target (System/getenv "TARGET")]
                   target
                   "World")
                 "!\n")})

   (defn -main [& args]
     (run-jetty handler {:port (if-let [port (System/getenv "PORT")]
                                 (Integer/parseInt port)
                                 8080)}))
   ```

1. In your project directory, create a file named `project.clj` and copy the
   code below into it. This code defines the project's dependencies and
   entrypoint.

   ```clojure
   (defproject helloworld "1.0.0-SNAPSHOT"
     :description "Hello World - Clojure sample"
     :dependencies [[org.clojure/clojure "1.9.0"]
                    [ring/ring-core "1.6.3"]
                    [ring/ring-jetty-adapter "1.6.3"]]
     :main helloworld.core)
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Clojure app,
   see
   [the clojure image documentation](https://github.com/docker-library/docs/tree/master/clojure).

   ```docker
   # Use the official Clojure image.
   # https://hub.docker.com/_/clojure
   FROM clojure

   # Create the project and download dependencies.
   WORKDIR /usr/src/app
   COPY project.clj .
   RUN lein deps

   # Copy local code to the container image.
   COPY . .

   # Build an uberjar release artifact.
   RUN mv "$(lein uberjar | sed -n 's/^Created \(.*standalone\.jar\)/\1/p')" app-standalone.jar

   # Run the web service on container startup.
   CMD ["java", "-jar", "app-standalone.jar"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-clojure
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-clojure
             env:
               - name: TARGET
                 value: "Clojure Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-clojure .

   # Push the container to docker registry
   docker push {username}/helloworld-clojure
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-clojure --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-clojure  http://helloworld-clojure.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-clojure.default.1.2.3.4.xip.io
   Hello World!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
