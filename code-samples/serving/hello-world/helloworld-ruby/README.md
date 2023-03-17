# Hello World - Ruby

This guide describes the steps required to create the `helloworld-ruby` sample app and deploy it to your cluster.

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`.
If `TARGET` is not specified, `World` is used as the default value.

You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-ruby
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- (optional) The Knative CLI client [kn](https://github.com/knative/client/releases) that simplifies the deployment. Alternative you can also use [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and apply resource files directly.

## Recreating the sample code

1. Create a new directory and cd into it:

   ```bash
   mkdir app
   cd app
   ```

1. Create a file named `app.rb` and copy the following code block into it:

   ```ruby
   require 'sinatra'

   set :bind, '0.0.0.0'

   get '/' do
    target = ENV['TARGET'] || 'World'
    "Hello #{target}!\n"
   end
   ```

1. Create a file named `Dockerfile` and copy the following code block into it. See
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

1. Create a file named `Gemfile` and copy the following text block into it.

   ```gem
   source 'https://rubygems.org'

   gem 'sinatra'
   gem 'rack', '>= 2.0.6'
   ```

1. Run bundle. If you don't have bundler installed, copy the
   [Gemfile.lock](Gemfile.lock) to your working directory.

   ```bash
   bundle install
   ```

1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{username}` with your Docker Hub username.

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

## Deploying

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster.

Choose one of the following methods to deploy the app:

 ### yaml

 * Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{username}` with your Docker Hub username.
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
Ensure that the container image value in `service.yaml` matches the container you built in the previous step.
Apply the configuration using `kubectl`:
```bash
kubectl apply --filename service.yaml
```

### kn
 * With `kn` you can deploy the service with:
```bash
kn service create helloworld-ruby --image=docker.io/{username}/helloworld-ruby --env TARGET="Ruby Sample v1"
```
This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.
The output will look like:
```
       Creating service 'helloworld-ruby' in namespace 'default':

        0.035s The Configuration is still working to reflect the latest desired specification.
        0.139s The Route is still working to reflect the latest desired specification.
        0.250s Configuration "helloworld-ruby" is waiting for a Revision to become ready.
        8.040s ...
        8.136s Ingress has not yet been reconciled.
        8.277s unsuccessfully observed a new generation
        8.398s Ready to serve.

      Service 'helloworld-ruby' created to latest revision 'helloworld-ruby-akhft-1' is available at URL:
      http://helloworld-ruby.default.1.2.3.4.sslip.io
    ```

During the creation of your service, Knative performs the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

## Verification

1. Run one of the followings commands to find the domain URL for your service.

 ### kubectl
```bash
kubectl get ksvc helloworld-ruby  --output=custom-columns=NAME:.metadata.name,URL:.status.url
```

 Example:
 ```bash
NAME                URL
helloworld-ruby     http://helloworld-ruby.default.1.2.3.4.sslip.io
 ```

 ### kn
```bash
kn service describe helloworld-ruby -o url
```
Example:
```bash
http://helloworld-ruby.default.1.2.3.4.sslip.io
```

2. Now you can make a request to your app and see the result.
Replace the following URL with the URL returned in the previous command.

 Example:

   ```bash
   curl http://helloworld-ruby.default.1.2.3.4.sslip.io
   Hello Ruby Sample v1!

   # Even easier with kn:
   curl $(kn service describe helloworld-ruby -o url)
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing

To remove the sample app from your cluster, delete the service record:

### kubectl
```bash
kubectl delete --filename service.yaml
```

### kn
```bash
kn service delete helloworld-ruby
```
