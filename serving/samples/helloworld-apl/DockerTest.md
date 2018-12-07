# How to test Docker image

Example how to build docker image for local docker test:
````docker
docker build --no-cache -t simple-apl:0.1 .
````

Docker image can be tested with:
````docker
docker run -it -p 8080:8080 --rm --env FUNC_HANDLER=helloWorld simple-apl:0.1
````