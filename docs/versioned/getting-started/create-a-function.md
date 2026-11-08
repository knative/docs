---
audience: developer
components:
  - functions
function: tutorial
---

# Creating a function

**Starting state:** You have [installed func](install-func.md). Work in a writable directory that does not already contain a `hello-function` project.

Use a different name from Quickstart's `hello` Service, so later deployment does not overwrite that exercise:

```bash
func create -l go hello-function
```

!!! success "Expected result"
    `func` reports that it created a Go function in `hello-function`. The new directory contains generated source, tests, and `func.yaml` project configuration.

Leave the generated function unchanged for this first exercise. Other languages and the `kn func` form are described in [creating functions](../functions/creating-functions.md); exact options are in the [func create command reference](https://github.com/knative/func/blob/main/docs/reference/func_create.md).

**Previous:** [Install func](install-func.md) · **Next:** [Run and deploy the function](build-run-deploy-func.md)
