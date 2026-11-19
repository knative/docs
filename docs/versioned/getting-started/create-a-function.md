---
audience: developer
components:
  - functions
function: tutorial
---

<span id="creating-a-function"></span>

# Create and change a function

From a directory where you keep projects, create a Go function using the HTTP template:

```bash
func create -l go -t http hello-function
cd hello-function
```

The command creates a new `hello-function` directory. Use a fresh directory
rather than overwriting an existing project.

## Change the response

Open `function.go` in your editor. Find the `Handle` method that writes the
HTTP response. In the generated Go template, it contains:

```go
fmt.Fprintln(res, "OK")
```

Replace that line with:

```go
fmt.Fprintln(res, "Hello from my function!")
```

Save the file. Leave the package, imports, constructor, and method signature
unchanged. You have changed what the function sends back to its caller.

The generated `func.yaml` describes the project. You do not need to edit it for
this lesson. `function_test.go` contains a starter Go test for future development.

Next, [run the function locally](build-run-deploy-func.md) and check that your
new message appears in its response.
