# Create your own event source

You can create your own event source to use with Knative by using one of the following methods:

- Create an event source in JavaScript, and implement it by using a [ContainerSource](../../containersource). Using a ContainerSource is a simple way to turn any dispatcher container into a Knative event source.
- Create an event source in JavaScript, and implement it by using [SinkBinding](../../sinkbinding). Using SinkBinding provides a framework for injecting environment variables into any Kubernetes resource that has a `spec.template` and is [PodSpecable](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#PodSpecable).
- Create your own event source controller, receiver adapter, and custom resource definition (CRD).

The ContainerSource and SinkBinding methods both work by injecting environment variables into an application. The injected environment variables at minimum contain the URL of a sink that receives events.

<!---QUESTION: Is this Bootstrapping bit really required or is it JS specific?-->
## Bootstrapping

Create the project and add the dependencies:

```bash
npm init
npm install cloudevents-sdk@2.0.1 --save
```

**NOTE:** Due to this [bug](https://github.com/cloudevents/sdk-javascript/issues/191), you must use version 2.0.1 of the Javascript SDK or newer.
