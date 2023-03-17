# Hello World - PHP

A simple web app written in PHP that you can use for testing. It reads in an env
variable `TARGET` and prints `Hello ${TARGET}!`. If `TARGET` is not specified,
it will use `World` as the `TARGET`.

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-php
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new directory and cd into it:

   ```bash
   mkdir app
   cd app
   ```

1. Create a file named `index.php` and copy the following code block into it:

   ```php
   <?php
   $target = getenv('TARGET', true) ?: 'World';
   echo sprintf("Hello %s!\n", $target);
   ?>
   ```

1. Create a file named `Dockerfile` and copy the following code block into it. See
   [official PHP docker image](https://hub.docker.com/_/php/) for more details.

   ```docker
   # Use the official PHP 7.3 image.
   # https://hub.docker.com/_/php
   FROM php:7.3-apache

   # Copy local code to the container image.
   COPY index.php /var/www/html/

   # Use the PORT environment variable in Apache configuration files.
   RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

   # Configure PHP for development.
   # Switch to the production php.ini for production operations.
   # RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
   # https://hub.docker.com/_/php#configuration
   RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
   ```

1. Create a `.dockerignore` file to ensure that any files related to a local
   build do not affect the container that you build for deployment.

   ```ignore
   README.md
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-php
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-php
             env:
               - name: TARGET
                 value: "PHP Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

Choose one of the following methods:

### yaml
 1. Use Docker to build the sample code into a container. To build and push with Docker Hub, run these commands replacing `{username}` with your Docker Hub username:

    ```bash
     # Build the container on your local machine
     docker build -t {username}/helloworld-php .

     # Push the container to docker registry
     docker push {username}/helloworld-php
     ```

 1. After the build has completed and the container is pushed to docker hub, you can deploy the app into your cluster. Ensure that the container image value in `service.yaml` matches the container you built in the previous step. Apply the configuration using `kubectl`:

 ```bash
 kubectl apply --filename service.yaml
 ```

### kn
 1. With `kn` you can deploy the service with

     ```bash
     kn service create helloworld-php --image=docker.io/{username}/helloworld-php --env TARGET="Ruby Sample v1"
     ```

     This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.

     The output will look like:
     ```
    Creating service 'helloworld-php' in namespace 'default':
    0.035s The Configuration is still working to reflect the latest desired specification.
    0.139s The Route is still working to reflect the latest desired specification.
    0.250s Configuration "helloworld-php" is waiting for a Revision to become ready.
    8.040s ...
    8.136s Ingress has not yet been reconciled.
    8.277s unsuccessfully observed a new generation
    8.398s Ready to serve.
    Service 'helloworld-php' created to latest revision 'helloworld-php-akhft-1' is available at URL: http://helloworld-php.default.1.2.3.4.xip.io
     ```

Now that your service is created, Knative will perform the following steps:

  - Create a new immutable revision for this version of the app.
  - Network programming to create a route, ingress, service, and a load balancer for your app.
  - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

 ### kubectl
 ```
 kubectl get ksvc helloworld-php  --output=custom columns=NAME:.metadata.name,URL:.status.url
 NAME                URL
 helloworld-php      http://helloworld-php.default.1.2.3.4.xip.io
 ```

 ### kn
 ```bash
kn service describe helloworld-php -o url
```
Example:
 ```bash
http://helloworld-php.default.1.2.3.4.xip.io
 ```
1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

 ```bash
curl http://helloworld-php.default.1.2.3.4.sslip.io
Hello PHP Sample v1!
 ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

### kubectl
```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete helloworld-php
```
