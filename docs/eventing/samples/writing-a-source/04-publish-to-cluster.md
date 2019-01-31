---
title: "Publish to a Kubernetes cluster"
weight: 40
---

So far we've only tested the controller code locally. Now we'd like to deploy it
to a cluster and test it working.

## Run the controller locally

Start a minikube cluster.

_If you already have a Kubernetes cluster running, you can skip this step. The
cluster must be 1.11+ if you enabled the status subresource earlier._

```sh
minikube start
```

Run `make install` to install the generated CRDs into the cluster.

```sh
make install
```

Run `make run` to run the controller process locally, talking to the
kubectl-configured cluster (this will be minikube if you used `minikube start`
earlier).

```sh
make run
```

In the reference project, this produces log output like this:

```json
{"level":"info","ts":1546896846.3001022,"logger":"kubebuilder.controller","msg":"Starting Controller","controller":"samplesource-controller"}
{"level":"info","ts":1546896846.4004664,"logger":"kubebuilder.controller","msg":"Starting workers","controller":"samplesource-controller","worker count":1}
```

## Create a sample source

In a different terminal, use `kubectl apply` to create a source.

```sh
kubectl apply -f config/samples
```

The controller should log an error saying that the sink reference is nil. In the
reference project, that error looks like this:

_Stacktraces in log messages have been elided for clarity._

```json
{"level":"error","ts":1546896989.0428371,"logger":"kubebuilder.controller","msg":"Reconciler error","controller":"samplesource-controller","request":"default/samplesource-sample","error":"Failed to get sink URI: sink reference is nil","stacktrace":"..."}
```

Create a TestSink CRD to use as an Addressable.

_If you already have an Addressable resource in your cluster, you can skip this
step._

```sh
echo "apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: testsinks.sources.knative.dev
spec:
  group: sources.knative.dev
  names:
    kind: TestSink
    plural: testsinks
  scope: Namespaced
  version: v1alpha1" | kubectl apply -f -
```

Create a TestSink object with an Addressable status.

```sh
echo "apiVersion: sources.knative.dev/v1alpha1
kind: TestSink
metadata:
  name: foosink
status:
  address:
    hostname: example.com" | kubectl apply -f -
```

Update the source to include a reference to the sink. In the reference project,
that command looks like this.

```sh
echo "apiVersion: sources.knative.dev/v1alpha1
kind: SampleSource
metadata:
  name: samplesource-sample
spec:
  sink:
    apiVersion: sources.knative.dev/v1alpha1
    kind: TestSink
    name: foosink
    namespace: default" | kubectl apply -f -
```

Check the controller logs in the first terminal. You should see an `Updated
Status` log line. In the reference project, that line looks like this:

```json
{"level":"info","ts":1546898070.4645903,"logger":"controller","msg":"Updating Status","request":{"namespace":"default","name":"samplesource-sample"}}
```

Verify that the source's SinkURI was updated by the controller. In the reference
project, that command looks like this.

```sh
kubectl get samplesources samplesource-sample -oyaml
```

We expect to see this in the output:

```yaml
spec:
  sink:
    apiVersion: sources.knative.dev/v1alpha1
    kind: TestSink
    name: foosink
    namespace: default
status:
  sinkURI: http://example.com/
```

## Run the controller in cluster

Normally controllers run inside the Kubernetes cluster. This requires publishing
a container image and creating several Kubernetes objects:

*   Namespace to run the controller pod in
*   StatefulSet or Deployment to manage the controller pod
*   RBAC rules granting permissions to manipulate Kubernetes resources

Export the `IMG` environment variable with a value equal to the desired
container image URL. This URL will be different depending on your container
image registry. The reference project uses Docker Hub.

```sh
export IMG=grantrodgers/samplesource-manager:latest
```

Run `make docker-build` to build the container image.

```sh
make docker-build
```

_Notice that after running this command, the
`config/default/manager_image_patch.yaml` file is updated with the URL of the
built image._

Run `make docker-push` to publish the container image.

```sh
make docker-push
```

Run `make deploy` to create the resources to run the controller in the
Kubernetes cluster. This will use the cluster referenced in the current
`kubectl` context.

```sh
make deploy
```

Verify that the controller is running by checking for a `Running` pod in the
correct namespace. This will be the project name suffixed with `-system`. In the
reference project, the namespace is `sample-source-system`.

```sh
kubectl get pods -n sample-source-system
```

Now you can use the verification procedure outlined above in
[Create a sample source](#create-a-sample-source).

Next: Dispatching Events
