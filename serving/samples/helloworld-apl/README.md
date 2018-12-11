# Hello World - APL sample

A simple web app written in APL that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello ${TARGET}!". If
TARGET is not specified, it will use "World" as the TARGET.

## Prerequisites

* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md) if you need
  to create one.
* [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step.
The following instructions recreate the source files from this folder.

1. Create a new directory and cd into it:

    ````shell
    mkdir app
    cd app
    ````
1. Create a new sub-directory for APL function and cd into it:

    ````shell
    mkdir aplcode
    cd app
    ````
1. Create a file named `HelloWorld.dyalog` and copy the code block below into it:

    ```apl
    res←helloWorld arg;sink;target
    ⎕←'Start helloWorld fn.'
    ⎕←'arg:'arg
    sink←arg
 
    _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}
    target←_getenv'TARGET'

    :If 0=⊃⍴target
        target←'World'
    :EndIf

    res←'Hello ',target

    ⎕←'End helloWorld fn.'
    ```

1. Create a new sub-directory APL webservice start-up code and cd into it:

    ````shell
    cd .. # cd back to app at app directory
    mkdir init
    cd init
    ````

1. Create a file named `init.apl` which is the  APL script started by APL intereter and copy the code block below into it:

    ```apl
    ⎕←'Starting knative APL runtime...'

    _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}

    apphome←_getenv'APP_HOME'
    ⎕←'APP_HOME:'apphome

    sink←⎕FX⊃⎕NGET (apphome,'/init/StartJsonServer.apl')1
    startJsonServer

    ⎕←'Closing knative APL runtime.'
    ```

1. Create a file named `StartJsonServer.apl` which starts JSNON server and copy the code block below into it:

    ```apl
    startJsonServer;_empty;_getenv;_log;apphome;fnname;folder;lx;nr;port;server;timeout
    _empty←{0∊⍴⍵}
    _getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}
    _log←{⎕←⍵}
    _log 'Start init. of JSON Server.'
 
    apphome←_getenv'APP_HOME'
    folder←apphome,'/aplcode'
    _log'Folder with apl code:'folder

    fnname←_getenv'FUNC_HANDLER'
    _log'FUNC_HANDLER:'fnname
    port←_getenv'PORT'
    timeout←_getenv'FUNC_TIMEOUT'
    _log'FUNC_TIMEOUT:'timeout
    :If ∨/lx←_empty¨port timeout
       (lx/(port timeout))←lx/'8080' '300'
    :EndIf
    port timeout←⍎¨port timeout
    wrrapername←'HandlerWrapper'
    _log'Making ',wrrapername,':'
    nr←⍬
    nr,←⊂' res←',wrrapername,' arg'
    nr,←⊂' ⍝ Handler wrapper.'
    nr,←⊂' res←(⍎''',fnname,''')arg'
    _log¨nr
    (⊂nr)⎕NPUT folder,'/',wrrapername,'.dyalog'

    ⎕CY'/JSONServer/Distribution/JSONServer.dws'

    server←⎕NEW #.JSONServer
    server.Port←port
    server.Timeout←timeout
    server.CodeLocation←folder
    server.Threaded←0
    server.AllowHttpGet←1
    server.Logging←1
    server.Handler←wrrapername
    server.HtmlInterface←0
    server.AccessControlAllowOrigin←''
    server.ContentType←'text/html; charset=utf-8' ⍝ or application/json; charset=utf-8

    _log'JSONServer argumnets:'
    _log'server.Port'server.Port
    _log'server.Timeout'server.Timeout
    _log'server.CodeLocation'server.CodeLocation
    _log'server.Threaded'server.Threaded
    _log'server.AllowHttpGet'server.AllowHttpGet
    _log'server.Logging'server.Logging
    _log'server.Handler'server.Handler
    _log'server.HtmlInterface'server.HtmlInterface
    _log'server.AccessControlAllowOrigin'server.AccessControlAllowOrigin
    _log'server.ContentType'server.ContentType

    _log'Starting server'

    server.Start

    _log'Stopped server'
    ```

1. Cd back to app at app directory:

    ````shell
    cd .. # cd back to app at app directory
    ````

1. Create a file named `Dockerfile` and copy the code block below into it.
   See [official Dyalog APL docker image](https://hub.docker.com/r/dyalog/dyalog/) for more details.

    ```docker 
    FROM dyalog/dyalog:17.1
    # Adjusting Dyalog image:
    # RRR: "run" is standard Linux folder!
    RUN rm /run
    # Entry point is not needed in Dyalog image.
    ENTRYPOINT []

    # Install dos2unix and git:
    RUN apt-get update
    RUN apt-get install dos2unix && apt-get install --assume-yes git

    # Markos JSON Server with thread control:
    RUN git clone https://github.com/mvranic/JSONServer.git /JSONServer 

    # Coping APL code and startup shell scripts to image:
    ENV APP_HOME /apphome
    COPY . $APP_HOME
    # Change mode for shell scripts:
    RUN find $APP_HOME -type f -iname "*.sh" -exec chmod +x {} \;
    # Format the text files:
    RUN find $APP_HOME -type f  \( -iname '*.sh' -o -iname '*.apl' -o -iname '*.dyalog' \) -print0 | xargs -0 dos2unix

    # Standard knative settings:
    WORKDIR $APP_HOME

    # Configure and document the service HTTP port.
    ENV PORT 8080
    EXPOSE $PORT

    # Run the web service on container startup.
    CMD ./init.sh
    ```

1. Create a new file `init.sh` shell script and which start `run-script.sh`.
   ```bash
    #!/bin/bash
    echo "Starts Dyalog APL image run(-script).sh"

    export CodeLocation=$APP_HOME/aplcode

    # Start updated Dyalog (with APL script support) image startup shell script:
    $APP_HOME/run-script.sh $APP_HOME/init/init.apl
   ```

1. Create a new file `run-script.sh`.
   ```bash
   #!/bin/bash

   ## This file replaces the Dyalog mapl script
   echo " _______     __      _      ____   _____ "
   echo "|  __ \ \   / //\   | |    / __ \ / ____|"
   echo "|_|  | \ \_/ //  \  | |   | |  | | |     "
   echo "     | |\   // /\ \ | |   | |  | | |   _ "
   echo " ____| | | |/ /  \ \| |___| |__| | |__| |"
   echo "|_____/  |_/_/    \_\______\____/ \_____|"
   echo ""
   echo "https://www.dyalog.com"
   echo ""
   echo "*************************************************************************************"
   echo "*               This software is for non-commercial evaluation ONLY                 *"
   echo "* https://www.dyalog.com/uploads/documents/Private_Personal_Educational_Licence.pdf *"
   echo "*************************************************************************************"
   echo ""

   export MAXWS=${MAXWS-256M}

   export DYALOG=/opt/mdyalog/17.1/64/unicode/
   export WSPATH=/opt/mdyalog/17.1/64/unicode/ws
   export TERM=xterm
   export APL_TEXTINAPLCORE=${APL_TEXTINAPLCORE-1}
   export TRACE_ON_ERROR=0
   export SESSION_FILE="${SESSION_FILE-$DYALOG/default.dse}"

   echo "Start up script at $@"
   # Used +s as SALT is needed in JSON server to load files.
   $DYALOG/dyalog +s <$@  # Add "<" to start APL script.
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub username.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-apl
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: docker.io/{username}/helloworld-apl
                env:
                - name: TARGET
                  value: "APL Sample v1"
                - name: FUNC_HANDLER
                  value: "helloWorld"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your
   Docker Hub username:

    ```shell
    # Build the container on your local machine
    docker build -t {username}/helloworld-apl .

    # Push the container to docker registry
    docker push {username}/helloworld-apl
    ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in
   the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply --filename service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, use
   `kubectl get svc knative-ingressgateway --namespace istio-system` to get the ingress IP for your
   cluster. If your cluster is new, it may take sometime for the service to get asssigned
   an external IP address.

    ```shell
    kubectl get svc knative-ingressgateway --namespace istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```

1. To find the URL for your service, use
    ```
    kubectl get ksvc helloworld-apl  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    NAME                DOMAIN
    helloworld-apl   helloworld-apl.default.example.com
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}`
   with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-apl.default.example.com" http://{IP_ADDRESS}
    Hello World: APL Sample v1!
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
