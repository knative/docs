A simple web app written in Go that you can use for testing. It demonstrates how
to use a Kubernetes secret as a Volume with Knative. We will create a new Google
Service Account and place it into a Kubernetes secret, then we will mount it
into a container as a Volume.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/secrets-go
```

## Before you begin

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../install/README.md) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- Create a
  [Google Cloud project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
  and install the `gcloud` CLI and run `gcloud auth login`. This sample will use
  a mix of `gcloud` and `kubectl` commands. The rest of the sample assumes that
  you've set the `$PROJECT_ID` environment variable to your Google Cloud project
  id, and also set your project ID as default using
  `gcloud config set project $PROJECT_ID`.

## Recreating the sample code

1. Create a new file named `secrets.go` and paste the following code. This code
   creates a basic web server which listens on port 8080:

   ```go
   package main

   import (
    "context"
    "fmt"
    "log"
    "net/http"
    "os"

    "cloud.google.com/go/storage"
   )

   func main() {
    log.Print("Secrets sample started.")

    // This sets up the standard GCS storage client, which will pull
    // credentials from GOOGLE_APPLICATION_CREDENTIALS if specified.
    ctx := context.Background()
    client, err := storage.NewClient(ctx)
    if err != nil {
      log.Fatalf("Unable to initialize storage client: %v", err)
    }

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
      // This GCS bucket has been configured so that any authenticated
      // user can access it (Read Only), so any Service Account can
      // run this sample.
      bkt := client.Bucket("knative-secrets-sample")

      // Access the attributes of this GCS bucket, and write it back to the
      // user.  On failure, return a 500 and the error message.
      attrs, err := bkt.Attrs(ctx)
      if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
      }
      fmt.Fprintln(w,
        fmt.Sprintf("bucket %s, created at %s, is located in %s with storage class %s\n",
          attrs.Name, attrs.Created, attrs.Location, attrs.StorageClass))

    })

    port := os.Getenv("PORT")
    if port == "" {
      port = "8080"
    }

    log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
   }
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Go app, see
   [Deploying Go servers with Docker](https://blog.golang.org/docker).

   ```docker
   # Use the offical Golang image to create a build artifact.
   # This is based on Debian and sets the GOPATH to /go.
   # https://hub.docker.com/_/golang
   FROM golang as builder

   # Install dep
   RUN go get -u github.com/golang/dep/cmd/dep

   # Copy local code to the container image.
   WORKDIR /go/src/github.com/knative/docs/hellosecrets
   COPY . .

   # Fetch dependencies
   RUN dep init
   RUN dep ensure

   # Build the output command inside the container.
   RUN CGO_ENABLED=0 GOOS=linux go build -v -o hellosecrets

   # Use a Docker multi-stage build to create a lean production image.
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM alpine

   # Enable the use of outbound https
   RUN apk add --no-cache ca-certificates

   # Copy the binary to the production image from the builder stage.
   COPY --from=builder /go/src/github.com/knative/docs/hellosecrets/hellosecrets /hellosecrets

   # Service must listen to $PORT environment variable.
   # This default value facilitates local development.
   ENV PORT 8080

   # Run the web service on container startup.
   CMD ["/hellosecrets"]
   ```

1. [Create a new Google Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts).
   This Service Account doesn't need any privileges, the GCS bucket has been
   configured so that any authenticated identity may read it.

   ```shell
   gcloud iam service-accounts create knative-secrets
   ```

1. Create a new JSON key for this account

   ```shell
   gcloud iam service-accounts keys create robot.json \
    --iam-account=knative-secrets@$PROJECT_ID.iam.gserviceaccount.com
   ```

1. Create a new Kubernetes secret from this JSON key:

   ```shell
   kubectl create secret generic google-robot-secret --from-file=./robot.json
   ```

   You can achieve a similar result by editting `secret.yaml`, copying the
   contents of `robot.json` as instructed there, and running
   `kubectl apply --filename secret.yaml`.

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: secrets-go
     namespace: default
   spec:
     template:
       spec:
         containers:
           # Replace {username} with your DockerHub username
           - image: docker.io/{username}/secrets-go

             env:
               # This directs the Google Cloud SDK to use the identity and project
               # defined by the Service Account (aka robot) in the JSON file at
               # this path.
               #  - `/var/secret` is determined by the `volumeMounts[0].mountPath`
               #   below. This can be changed if both places are changed.
               #  - `robot.json` is determined by the "key" that is used to hold the
               #   secret content in the Kubernetes secret.  This can be changed
               #   if both places are changed.
               - name: GOOGLE_APPLICATION_CREDENTIALS
                 value: /var/secret/robot.json

             # This section specified where in the container we want the
             # volume containing our secret to be mounted.
             volumeMounts:
               - name: robot-secret
                 mountPath: /var/secret

         # This section attaches the secret "google-robot-secret" to
         # the Pod holding the user container.
         volumes:
           - name: robot-secret
             secret:
               secretName: google-robot-secret
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/secrets-go .

   # Push the container to docker registry
   docker push {username}/secrets-go
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

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc secrets-go  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME             URL
   secrets-go       http://secrets-go.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://secrets-go.default.1.2.3.4.xip.io
   bucket knative-secrets-sample, created at 2019-02-01 14:44:05.804 +0000 UTC, is located in US with storage class MULTI_REGIONAL
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
kubectl delete secret google-robot-secret
```
