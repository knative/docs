# Building, running, or deploying functions

After you have created a function project, you can build, run, or deploy your function, depending on your use case.

## Running a function

--8<-- "run-func-intro.md"

### Prerequisites

- You have a Docker daemon on your local machine. This is already provided if you have used the Quickstart installation.

### Procedure

--8<-- "proc-running-function.md"

## Deploying a function

--8<-- "deploy-func-intro.md"

### Prerequisites

- You have a Docker daemon on your local machine. This is already provided if you have used the Quickstart installation.

- You have access to a container registry and are able to push images to this registry. Note that some image registries set newly pushed images to private by default. If you are deploying a function for the first time, you may need to ensure that your images are set to public.

### Procedure

--8<-- "proc-deploying-function.md"

## Building a function

--8<-- "build-func-intro.md"

### Prerequisites

- You have a Docker daemon on your local machine. This is already provided if you have used the Quickstart installation.

### Procedure

--8<-- "proc-building-function.md"
