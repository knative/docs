A microservice which demonstrates how to get set up and running with Knative
Serving when using [Scala](https://scala-lang.org/) and [Akka](https://akka.io/)
[HTTP](https://doc.akka.io/docs/akka-http/current/). It will respond to a HTTP
request with a text specified as an `ENV` variable named `MESSAGE`, defaulting
to `"Hello World!"`.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-scala
```

## Before you begin

- A Kubernetes cluster [installation](../../../../install/README.md) with
  Knative Serving up and running.
- [Docker](https://www.docker.com) installed locally, and running, optionally a
  Docker Hub account configured or some other Docker Repository installed
  locally.
- [Java JDK8 or later](https://adoptopenjdk.net/installation.html) installed
  locally.
- [Scala's](https://scala-lang.org/) standard build tool
  [sbt](https://www.scala-sbt.org/) installed locally.

## Configuring the Service descriptor

Importantly, in [service.yaml](./service.yaml) **change the
image reference to match up with your designated repository**, i.e. replace
`{username}` with your Dockerhub username in the example below.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-scala
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: docker.io/{username}/helloworld-scala
          env:
            - name: MESSAGE
              value: "Scala & Akka on Knative says hello!"
            - name: HOST
              value: "localhost"
```

## Publishing to Docker

In order to build the project and create and push the Docker image, run:

```shell
# Build the container on your local machine
docker build -t {username}/helloworld-scala .

# Push the container to docker registry
docker push {username}/helloworld-scala
```

## Deploying to Knative Serving

Apply the [Service yaml definition](./helloworld-scala.yaml):

```shell
kubectl apply --filename helloworld-scala.yaml
```

Then find the service host:

```shell
kubectl get ksvc helloworld-scala \
    --output=custom-columns=NAME:.metadata.name,URL:.status.url

# It will print something like this, the URL is what you're looking for.
# NAME                URL
# helloworld-scala    http://helloworld-scala.default.1.2.3.4.xip.io
```

Finally, to try your service, use the obtained URL:

```shell
curl -v http://helloworld-scala.default.1.2.3.4.xip.io
```

## Cleanup

```shell
kubectl delete --filename helloworld-scala.yaml
```

```
kubetl delete --filename helloworld-scala.yaml
```
