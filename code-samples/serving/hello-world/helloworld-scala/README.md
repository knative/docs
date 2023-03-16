# Hello World - Scala using Akka HTTP

A microservice which demonstrates how to get set up and running with Knative
Serving when using [Scala](https://scala-lang.org/) and [Akka](https://akka.io/)
[HTTP](https://doc.akka.io/docs/akka-http/current/). It will respond to a HTTP
request with a text specified as an `ENV` variable named `MESSAGE`, defaulting
to `"Hello World!"`.

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-scala
```

## Before you begin

- A Kubernetes cluster with Knative Serving up and running. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed locally, and running, optionally a
  Docker Hub account configured or some other Docker Repository installed
  locally.
- [Java JDK8 or later](https://adoptopenjdk.net/installation.html) installed
  locally.
- [Scala's](https://scala-lang.org/) standard build tool
  [sbt](https://www.scala-sbt.org/) installed locally.

## Configuring the sbt build

If you want to use your Docker Hub repository, set the repository to
"docker.io/yourusername/yourreponame".

If you use Minikube, you first need to run:

```bash
eval $(minikube docker-env)
```

If want to use the Docker Repository inside Minikube, either set this to
"dev.local" or if you want to use another repository name, then you need to run
the following command after `docker:publishLocal`:

```bash
docker tag yourreponame/helloworld-scala:<version> dev.local/helloworld-scala:<version>
```

Otherwise Knative Serving won't be able to resolve this image from the Minikube
Docker Repository.

You specify the repository in [build.sbt](build.sbt):

```scala
dockerRepository := Some("your_repository_name")
```

You can learn more about the build configuration syntax
[here](https://www.scala-sbt.org/1.x/docs/Basic-Def.html).

## Configuring the Service descriptor

Importantly, in the `service.yaml` file, **change the
image reference to match up with the repository**, name, and version specified
in the [build.sbt](build.sbt) in the previous section.

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
        - image: "your_repository_name/helloworld-scala:0.0.1"
          env:
            - name: MESSAGE
              value: "Scala & Akka on Knative says hello!"
            - name: HOST
              value: "localhost"
```

## Publishing to Docker

In order to build the project and create and push the Docker image, run either:

```bash
sbt docker:publishLocal
```

or

```bash
sbt docker:publish
```

Which of them to use is depending on whether you are publishing to a remote or a
local Docker Repository.

## Deploying to Knative Serving


### yaml

Apply the [Service yaml definition](service.yaml):

```bash
kubectl apply -f service.yaml
```

### kn

With `kn` you can deploy the service with

 ```bash
kn service create helloworld-scala --image=docker.io/{username}/helloworld-scala --env TARGET="Scala Sample v1"
 ```

 This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.

 The output will look like:

 ```
 Creating service 'helloworld-scala' in namespace 'default':
 0.035s The Configuration is still working to reflect the latest desired specification.
 0.139s The Route is still working to reflect the latest desired specification.
 0.250s Configuration "helloworld-scala" is waiting for a Revision to become ready.
 8.040s ...
 8.136s Ingress has not yet been reconciled.
 8.277s unsuccessfully observed a new generation
 8.398s Ready to serve.

 Service 'helloworld-scala' created to latest revision 'helloworld-scala-abcd-1' is available at URL:
 http://helloworld-scala.default.1.2.3.4.sslip.io
```

### kubectl

 1. Find the service host:
 ```bash
kubectl get ksvc helloworld-scala \
--output=custom-columns=NAME:.metadata.name,URL:.status.url
# It will print something like this, the URL is what you're looking for.
# NAME                URL
# helloworld-scala    http://helloworld-scala.default.1.2.3.4.sslip.io
 ```

2. Finally, to try your service, use the obtained URL:

 ```bash
curl -v http://helloworld-scala.default.1.2.3.4.sslip.io
 ```


### kn
 1. Find the service host:
```bash
kn service describe helloworld-scala -o url
```

 Example:

 ```bash
 http://helloworld-scala.default.1.2.3.4.sslip.io
 ```

2. Finally, to try your service, use the obtained URL:

 ```bash
 curl -v http://helloworld-scala.default.1.2.3.4.sslip.io
 ```

## Cleanup

### kubectl

```bash
kubectl delete -f service.yaml
```

### kn

```bash
kn service delete helloworld-scala
```
