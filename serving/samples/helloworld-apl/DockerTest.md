# How to test knative APL Docker image

Example how to build docker image for local docker test:
````docker
docker build -t simple-apl:0.1 .
````

Docker image can be tested with:
````docker
docker run -it -p 8080:8080 --rm --env FUNC_HANDLER=helloWorld --env TARGET=FromAPL  simple-apl:0.1
````

Then use curl example from [Hello World - APL sample](README.md).