# Hello World - Scala using Akka HTTP sample

A microservice which demonstrates how to get set up and running with Knative
Serving when using [Scala](https://scala-lang.org/) and [Akka](https://akka.io/)
[HTTP](https://doc.akka.io/docs/akka-http/current/). It will respond to a HTTP
request with a text specified as an `ENV` variable named `MESSAGE`, defaulting
to `"Hello World!"`.

## Prerequisites

- A Kubernetes cluster
  [installation](https://github.com/knative/docs/blob/master/install/README.md)
  with Knative Serving up and running.
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

```shell
eval $(minikube docker-env)
```

If want to use the Docker Repository inside Minikube, either set this to
"dev.local" or if you want to use another repository name, then you need to run
the following command after `docker:publishLocal`:

```shell
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

Importantly, in [helloworld-scala.yaml](helloworld-scala.yaml) **change the
image reference to match up with the repository**, name, and version specified
in the [build.sbt](build.sbt) in the previous section.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: helloworld-scala
  namespace: default
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: "your_repository_name/helloworld-scala:0.0.1"
            imagePullPolicy: IfNotPresent
            env:
              - name: MESSAGE
                value: "Scala & Akka on Knative says hello!"
              - name: HOST
                value: "localhost"
```

## Publishing to Docker

In order to build the project and create and push the Docker image, run either:

```shell
sbt docker:publishLocal
```

or

```shell
sbt docker:publish
```

Which of them to use is depending on whether you are publishing to a remote or a
local Docker Repository.

## Deploying to Knative Serving

Locate the Knative Serving gateway address:

```shell
# In Knative 0.2.x and prior versions, `knative-ingressgateway` service was used instead of `istio-ingressgateway`.

kubectl get svc istio-ingressgateway -n istio-system
```

Example output, see the address under **EXTERNAL-IP**:

```shell
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP       PORTS)                                      AGE
xxxxxxx-ingressgateway   LoadBalancer   123.456.789.01   111.111.111.111   80:32380/TCP,443:32390/TCP,32400:32400/TCP   1m
```

Then export the external address obtained for ease of reuse later:

```shell
export SERVING_GATEWAY=<replace this with the address obtained>
```

If you use Minikube, then you will likely have to do the following instead:

```shell
export SERVING_GATEWAY=$(minikube ip):$(kubectl get svc istio-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

Apply the [Service yaml definition](helloworld-scala.yaml):

```shell
kubectl apply -f helloworld-scala.yaml
```

Then find the service host:

```shell
kubectl get ksvc helloworld-scala \
    -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain

# It will print something like this, the DOMAIN is what you're going to use as HTTP Host header:
# NAME                DOMAIN
# helloworld-scala    helloworld-scala.default.example.com
```

Finally, to try your service, use the obtained address in the Host header:

```shell
curl -v -H "Host: helloworld-scala.default.example.com" http://$SERVING_GATEWAY
```

## Cleanup

```shell
kubectl delete -f helloworld-scala.yaml
```
