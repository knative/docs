A simple web app that executes a shell script. The shell script reads an env
variable `TARGET` and prints `Hello ${TARGET}!`. If the `TARGET` environment
variable is not specified, the script uses `World`.

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

1. Create a new file named `script.sh` and paste the following script:

   ```sh
   #!/bin/sh
   echo Hello ${TARGET:=World}!
   ```

1. Create a new file named `invoke.go` and paste the following code. We use a
   basic web server written in Go to execute the shell script:

   ```go
   package main

   import (
       "fmt"
       "log"
       "net/http"
       "os"
       "os/exec"
   )

   func handler(w http.ResponseWriter, r *http.Request) {
       cmd := exec.CommandContext(r.Context(), "/bin/sh", "script.sh")
       cmd.Stderr = os.Stderr
       out, err := cmd.Output()
       if err != nil {
           w.WriteHeader(500)
       }
       w.Write(out)
   }

   func main() {
       http.HandleFunc("/", handler)

       port := os.Getenv("PORT")
       if port == "" {
           port = "8080"
       }

       log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
   }
   ```

1. Create a new file named `Dockerfile` and copy the code block below into it.

   ```docker
   FROM golang:1.11

   WORKDIR /go/src/invoke

   COPY invoke.go .
   RUN go install -v

   COPY . .

   CMD ["invoke"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
       name: helloworld-shell
       namespace: default
   spec:
       runLatest:
       configuration:
           revisionTemplate:
           spec:
               container:
               image: docker.io/{username}/helloworld-shell
               env:
                   - name: TARGET
                   value: "Shell Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-shell .

   # Push the container to docker registry
   docker push {username}/helloworld-shell
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

1. Run the following command to find the external IP address for your service.
   The ingress IP for your cluster is returned. If you just created your
   cluster, you might need to wait and rerun the command until your service gets
   asssigned an external IP address.

   ```shell
   kubectl get svc knative-ingressgateway --namespace istio-system
   ```

   Example:

   ```shell
   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   ```

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc helloworld-shell  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   ```

   Example:

   ```shell
   NAME                DOMAIN
   helloworld-shell       helloworld-shell.default.example.com
   ```

1. Test your app by sending it a request. Use the following `curl` command with
   the domain URL `helloworld-shell.default.example.com` and `EXTERNAL-IP`
   address that you retrieved in the previous steps:

   ```shell
   curl -H "Host: helloworld-shell.default.example.com" http://{EXTERNAL_IP_ADDRESS}
   ```

   Example:

   ```shell
   curl -H "Host: helloworld-shell.default.example.com" http://35.203.155.229
   Hello Shell Sample v1!
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
