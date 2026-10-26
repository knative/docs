# Hello world - .NET

A simple web app written in C# using .NET 10 LTS that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET
is not specified, it will use "World" as the TARGET.

Clone the sample, then build and deploy the app to your
cluster:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-csharp
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- Optional: [.NET SDK 10.0](https://dotnet.microsoft.com/download/dotnet/10.0) for
  local development. The supplied Dockerfile includes the SDK; no local .NET
  installation is needed to build or run the supplied sample.

The SDK and runtime images track the stable `10.0` LTS channel so rebuilds pick up
servicing updates. See Microsoft's [.NET support policy](https://dotnet.microsoft.com/platform/support/policy/dotnet-core).

## Understanding the sample files

- [Program.cs](Program.cs) is the complete minimal HTTP app. It binds to all
  interfaces on `PORT` (default `8080`), as required for container access. An
  absent `TARGET` defaults to `World`; an explicitly empty `TARGET` stays empty.
- [helloworld-csharp.csproj](helloworld-csharp.csproj) targets `net10.0`.
- [Dockerfile](Dockerfile) restores and publishes with the .NET 10 SDK, then copies
  the result into the matching ASP.NET Core runtime image. For background, see
  [Docker images for ASP.NET Core](https://learn.microsoft.com/aspnet/core/host-and-deploy/docker/building-net-docker-images).
- [service.yaml](service.yaml) is the Knative Service definition, including
  `TARGET="C# Sample v1"`. Replace `{username}` in its image reference with your
  Docker Hub username before applying it.

## Building and deploying the sample

From the cloned sample directory, build and deploy the supplied files:

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-csharp" --push .
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-csharp  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-csharp   http://helloworld-csharp.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   ```bash
   curl http://helloworld-csharp.default.1.2.3.4.sslip.io
   Hello C# Sample v1!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
