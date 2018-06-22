# Hello World - .NET Core sample

This sample application shows how to create a hello world application in C# using .NET Core 2.0.

## Assumptions

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this. 
* You have installed and initalized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.
* You have installed [.NET Core SDK 2.1](https://www.microsoft.com/net/core).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are generally more useful if you build them step-by-step. The following instructions recreate the source files from this folder.

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

1. Create a new file, `app.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google Cloud project. If you are using docker or another container registry instead, replace the entire image path.

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

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command:

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-csharp
    ```

1. After the build has completed, you can deploy the app into your cluster. Ensure that the container image value in `app.yaml` matches the container you build in the previous step. Apply the configuration using kubectl:

    ```shell
    kubectl apply -f app.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use kubectl to list the ingress points in the cluster:

    ```shell
    kubectl get ing

    NAME                        HOSTS                                                                                   ADDRESS        PORTS     AGE
    helloworld-csharp-ingress   helloworld-csharp.default.demo-domain.com,*.helloworld-csharp.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-csharp.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World!
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f app.yaml
```