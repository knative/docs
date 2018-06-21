# .NET Core Hello World sample

This sample application shows how to create a hello world application in C# using .NET Core 2.0.

## Assumptions

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this. 
* You have installed and initalized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.

## Steps to recreate the sample

1. Install the [.NET Core SDK 2.1](https://www.microsoft.com/net/core).
1. From the console, create a new empty web project using the dotnet command:

    ```shell
    dotnet new web -o helloworld-csharp
    ```

1. Update the `CreateWebHostBuilder` definition in `Program.cs` by adding `.UseUrls("http://0.0.0.0:8080")` to define the serving port:

    ```csharp
    public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
        WebHost.CreateDefaultBuilder(args)
            .UseStartup<Startup>().UseUrls("http://0.0.0.0:8080");
    ```

1. In your project directory, create a file named `Dockerfile` and copy the code block below into it. For detailed instructions on dockerizing a .NET core app, see [dockerizing a .NET core app](https://docs.microsoft.com/en-us/dotnet/core/docker/docker-basics-dotnet-core#dockerize-the-net-core-application).

    ```docker
    FROM microsoft/dotnet:2.1-sdk
    WORKDIR /app

    # copy csproj and restore as distinct layers
    COPY *.csproj ./
    RUN dotnet restore

    # copy and build everything else
    COPY . ./
    RUN dotnet publish -c Release -o out
    ENTRYPOINT ["dotnet", "out/helloworld-csharp.dll"]
    ```

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. You can use [docker](http://www.docker.com) as another option. To use container builder:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-csharp
    ```

1. After the build has completed, you are ready to deploy this app into your cluster. Create a new file, `app.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the value used in the previous step.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    name: csharp-demo
    namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: gcr.io/{PROJECT_ID}/helloworld-csharp
    ```

1. Apply this YAML file to your cluster using kubectl:

    ```shell
    kubectl apply -f app.yaml
    ```

1. Now that your service is registered in Kubernetes, Knative will take over and perform the following steps:
   * Network programming to create an ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use kubectl to list the ingress points in the cluster:

    ```shell
    kubectl get ing
    ```

This will return a list of ingress points and their hostnames:

    ```
    NAME                        HOSTS                                                                                   ADDRESS        PORTS     AGE
    helloworld-csharp-ingress   helloworld-csharp.default.demo-domain.com,*.helloworld-csharp.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result:

    ```shell
    curl -H "Host: helloworld-csharp.default.demo-domain.com" http://35.232.134.1
    Hello World!
    ```

## Remove the sample app

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f app.yaml
```