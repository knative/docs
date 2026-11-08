---
audience: developer
components:
  - functions
function: tutorial
---

# Creating a function

**Starting state:** You have [installed the selected func release](install-func.md) and have a text editor. Work in a writable directory that does not already contain a `hello-function` project. No cluster is needed for this lesson.

## Create a Go HTTP project

Use a different name from Quickstart's `hello` Service, so later deployment does not overwrite that exercise:

```bash
func create --language go --template http hello-function
```

!!! success "Expected result"
    `func` reports that it created a Go function in `hello-function`. The new directory contains generated source, tests, and `func.yaml` project configuration.

## Write a recognizable response

Open `hello-function/function.go`. In the selected release's generated `MyFunction.Handle` method, find:

```go
fmt.Fprintln(res, "OK")
```

Replace **only that line** with:

```go
fmt.Fprintln(res, "Hello from Knative Functions!")
```

The resulting handler is:

```go
func (f *MyFunction) Handle(res http.ResponseWriter, req *http.Request) {
    fmt.Fprintln(res, "Hello from Knative Functions!")
}
```

Save the file. Keep the rest of the generated file, imports, constructor, project configuration, and tests unchanged. This handler writes a fixed HTTP response; it does not process a CloudEvent or subscribe to a Broker. The next lesson runs it and checks the response you just chose.

If the generated method differs, stop and check your CLI release against [installation](install-func.md) and the [selected Go HTTP template source](https://github.com/knative/func/blob/knative-v1.23.0/templates/go/http/function.go). Do not replace an unfamiliar file wholesale with this excerpt.

Other languages and command forms belong in [creating functions](../functions/creating-functions.md). Exact options remain in the [func create command reference](https://github.com/knative/func/blob/knative-v1.23.0/docs/reference/func_create.md).

**Previous:** [Install func](install-func.md) · **Next:** [Run and deploy the function](build-run-deploy-func.md)
