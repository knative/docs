A simple web app written in Haskell that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified, it will use "World" as the TARGET.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../install/README.md) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new file named `stack.yaml` and paste the following code:

   ```yaml
   flags: {}
   packages:
     - .
   extra-deps: []
   resolver: lts-10.7
   ```

1. Create a new file named `package.yaml` and paste the following code

   ```yaml
   name: helloworld-haskell
   version: 0.1.0.0
   dependencies:
     - base >= 4.7 && < 5
     - scotty
     - text

   executables:
     helloworld-haskell-exe:
       main: Main.hs
       source-dirs: app
       ghc-options:
         - -threaded
         - -rtsopts
         - -with-rtsopts=-N
   ```

1. Create a `app` folder, then create a new file named `Main.hs` in that folder
   and paste the following code. This code creates a basic web server which
   listens on port 8080:

   ```haskell
   {-# LANGUAGE OverloadedStrings #-}

   import           Data.Maybe
   import           Data.Monoid        ((<>))
   import           Data.Text.Lazy     (Text)
   import           Data.Text.Lazy
   import           System.Environment (lookupEnv)
   import           Web.Scotty         (ActionM, ScottyM, scotty)
   import           Web.Scotty.Trans

   main :: IO ()
   main = do
     t <- fromMaybe "World" <$> lookupEnv "TARGET"
     pStr <- fromMaybe "8080" <$> lookupEnv "PORT"
     let p = read pStr :: Int
     scotty p (route t)

   route :: String -> ScottyM()
   route t = get "/" $ hello t

   hello :: String -> ActionM()
   hello t = text $ pack ("Hello " ++ t)
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it.

   ```docker
   # Use the official Haskell image to create a build artifact.
   # https://hub.docker.com/_/haskell/
   FROM haskell:8.2.2 as builder

   # Copy local code to the container image.
   WORKDIR /app
   COPY . .

   # Build and test our code, then build the “helloworld-haskell-exe” executable.
   RUN stack setup
   RUN stack build --copy-bins

   # Use a Docker multi-stage build to create a lean production image.
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM fpco/haskell-scratch:integer-gmp

   # Copy the "helloworld-haskell-exe" executable from the builder stage to the production image.
   WORKDIR /root/
   COPY --from=builder /root/.local/bin/helloworld-haskell-exe .

   # Run the web service on container startup.
   CMD ["./helloworld-haskell-exe"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
     name: helloworld-haskell
     namespace: default
   spec:
     runLatest:
       configuration:
         revisionTemplate:
           spec:
             container:
               image: docker.io/{username}/helloworld-haskell
               env:
                 - name: TARGET
                   value: "Haskell Sample v1"
   ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, enter these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-haskell .

   # Push the container to docker registry
   docker push {username}/helloworld-haskell
   ```

1. After the build has completed and the container is pushed to Docker Hub, you
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

1. To find the IP address for your service, enter these commands to get the
   ingress IP for your cluster. If your cluster is new, it may take some time
   for the service to get assigned an external IP address.

   ```shell
   # In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
   INGRESSGATEWAY=knative-ingressgateway

   # The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
   # Use `istio-ingressgateway` instead, since `knative-ingressgateway`
   # will be removed in Knative v0.4.
   if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
   fi

   kubectl get svc $INGRESSGATEWAY --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   ```

   For minikube or bare-metal, get IP_ADDRESS by running the following command

   ```shell
   echo $(kubectl get node  --output 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')

   ```

1. To find the URL for your service, enter:

   ```
   kubectl get ksvc helloworld-haskell  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                   URL
   helloworld-haskell     http://helloworld-haskell.default.example.com
   ```

1. Now you can make a request to your app and see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

   ```shell
   curl -H "Host: helloworld-haskell.default.example.com" http://{IP_ADDRESS}
   Hello world: Haskell Sample v1
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
