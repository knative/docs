A simple web app written in Ruby that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified, it will use "World" as the TARGET.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-ruby
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new directory and cd into it:

   ```shell
   mkdir app
   cd app
   ```

1. Create a file named `app.rb` and copy the code block below into it:

   ```ruby
   require 'sinatra'

   set :bind, '0.0.0.0'

   get '/' do
    target = ENV['TARGET'] || 'World'
    "Hello #{target}!\n"
   end
   ```

1. Create a file named `Dockerfile` and copy the code block below into it. See
   [official Ruby docker image](https://hub.docker.com/_/ruby/) for more
   details.

   ```docker
   # Use the official lightweight Ruby image.
   # https://hub.docker.com/_/ruby
   FROM ruby:2.6-slim

   # Install production dependencies.
   WORKDIR /usr/src/app
   COPY Gemfile Gemfile.lock ./
   ENV BUNDLE_FROZEN=true
   RUN gem install bundler && bundle install

   # Copy local code to the container image.
   COPY . ./

   # Run the web service on container startup.
   CMD ["ruby", "./app.rb"]
   ```

1. Create a file named `Gemfile` and copy the text block below into it.

   ```gem
   source 'https://rubygems.org'

   gem 'sinatra'
   gem 'rack', '>= 2.0.6'
   ```

1. Run bundle. If you don't have bundler installed, copy the
   [Gemfile.lock](./Gemfile.lock) to your working directory.

   ```shell
   bundle install
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-ruby
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-ruby
             env:
               - name: TARGET
                 value: "Ruby Sample v1"
   ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-ruby .

   # Push the container to docker registry
   docker push {username}/helloworld-ruby
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

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-ruby  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-ruby     http://helloworld-ruby.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-ruby.default.1.2.3.4.xip.io
   Hello Ruby Sample v1!
   ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
