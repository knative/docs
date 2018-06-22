# Hello World - Ruby sample

This sample application shows how to create a hello world application in Ruby.
When called, this application reads an env variable 'TARGET' 
and prints "Hello World: ${TARGET}!".
If TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this. 
* You have installed and initialized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are generally more useful if you build them step-by-step. The following instructions recreate the source files from this folder.

1. Create a new directory and cd into it:
    ````shell
    mkdir app
    cd app
    ````
1. Create a file named `app.rb` and copy the code block below into it:

    ```ruby
    require 'sinatra'

    set :bind, '0.0.0.0'

    get '/' do
      target = ENV['TARGET'] || 'NOT SPECIFIED'
      "Hello World: %s!\n" % [target]
    end
    ```

1. Create a file named `Dockerfile` and copy the code block below into it. See [official Ruby docker image](https://hub.docker.com/_/ruby/) for more details.

    ```docker
    FROM ruby:2.5

    RUN bundle config --global frozen 1

    WORKDIR /usr/src/app
    COPY Gemfile Gemfile.lock ./
    RUN bundle install

    COPY . .

    ENV PORT 8080
    EXPOSE 8080

    CMD ["ruby", "./app.rb"]
    ```

1. Create a file named `Gemfile` and copy the text block below into it.

    ```
    source 'https://rubygems.org'

    gem 'rack'
    gem 'sinatra'
    ```

1. Create a file named `Gemfile.lock` and copy the text block below into it.

    ```
    GEM
    remote: https://rubygems.org/
    specs:
        mustermann (1.0.2)
        rack (2.0.5)
        rack-protection (2.0.3)
        rack
        sinatra (2.0.3)
        mustermann (~> 1.0)
        rack (~> 2.0)
        rack-protection (= 2.0.3)
        tilt (~> 2.0)
        tilt (2.0.8)

    PLATFORMS
    ruby

    DEPENDENCIES
    rack
    sinatra

    BUNDLED WITH
    1.16.2
    ```

1. Create a file named `app.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google Cloud project. If you are using docker or another container registry instead, replace the entire image path.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-ruby
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: gcr.io/mdemirhantestproject/helloworld-ruby
                env:
                - name: TARGET
                  value: "Ruby Sample v1"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command. Make sure to replace `${PROJECT_ID}` with the ID of your Google Cloud project.

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-ruby
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
    helloworld-ruby-ingress   helloworld-ruby.default.demo-domain.com,*.helloworld-ruby.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-ruby.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: Ruby Sample v1!
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f app.yaml
```
