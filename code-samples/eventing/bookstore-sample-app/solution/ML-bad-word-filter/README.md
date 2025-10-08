# Python CloudEvents Function

Welcome to your new Python Function! A minimal Function implementation can
be found in `./function/func.py`.

For more, run `func --help` or read the [Python Functions doc](https://github.com/knative/func/blob/main/docs/function-templates/python.md)

## Usage

Knative Functions allow for the deployment of your source code directly to a
Kubernetes cluster with Knative installed.

### Function Structure

Python functions must implement a `new()` method that returns a function
instance. The function class can optionally implement:
- `handle()` - Process CloudEvent requests
- `start()` - Initialize the function with configuration
- `stop()` - Clean up resources when the function stops
- `alive()` / `ready()` - Health and readiness checks

See the default implementation in `./function/func.py`

### Running Locally

Use `func run` to test your Function locally before deployment.
For development environments where Python is installed, it's suggested to use
the `host` builder as follows:

```bash
# Run function on the host (outsdie of a container)
func run --builder=host
```

### Deploying

Use `func deploy` to deploy your Function to a Knative-enabled cluster:

```bash
# Deploy with interactive prompts (recommended for first deployment)
func deploy --registry ghcr.io/myuser
```

Functions are automatically built, containerized, and pushed to a registry
before deployment. Subsequent deployments will update the existing function.

## Roadmap

Our project roadmap can be found: https://github.com/orgs/knative/projects/49

