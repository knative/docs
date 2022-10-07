# Creating a Knative Function

Functions are the easiest path to get started with
Knative, providing a programming model that leverages the Knative
Serving and Eventing APIs for a quick and easy method of deploying your
first Knative applications. You don't need to know anything
about Knative or even Kubernetes resources to get started.

The purpose of this tutorial is to:

- Help you quickly go from a business need to a running application
- Demonstrate that you do not need Kubernetes knowledge to run a Knative application
- Show that it is easy to build small integrations which can connect to a larger ecosystem
- Provide a foundation from which you can begin to explore the rest of Knative and Kubernetes when you need it

In this tutorial, you will create and deploy a Knative Function in Go that
responds to HTTP requests. Create the function by running the command:

=== "func"

    ```{ .console}
    func create hello
    ```

=== "kn func"

    ```{ .console }
    kn func create -l go hello
    ```

!!! Success "Expected output"
    ```{ .console .no-copy }
    Created go function in hello
    ```

That's it. You have created your first Knative Function.
Let's take a look at the project before deploying it.
In the `hello` directory, you will find a few files.
The `handle.go` file is where you will implement your
application logic. There is also a `handle_test.go` file
where you can add unit tests for your business logic. Let's
take a quick look at those two files.

=== "handle.go"

      Here you can see that the function is responding to an HTTP request by printing
      the request information to the console, and returning that same information.
      In a real application, you would replace this code with your own business logic.

      ```go
      package function

      import (
        "context"
        "fmt"
        "net/http"
        "strings"
      )

      // Handle an HTTP Request.
      func Handle(ctx context.Context, res http.ResponseWriter, req *http.Request) {
        /*
        * YOUR CODE HERE
        *
        * Try running `go test`.  Add more test as you code in `handle_test.go`.
        */

        fmt.Println("Received request")
        fmt.Println(prettyPrint(req))      // echo to local output
        fmt.Fprintf(res, prettyPrint(req)) // echo to caller
      }

      func prettyPrint(req *http.Request) string {
        b := &strings.Builder{}
        fmt.Fprintf(b, "%v %v %v %v\n", req.Method, req.URL, req.Proto, req.Host)
        for k, vv := range req.Header {
          for _, v := range vv {
            fmt.Fprintf(b, "  %v: %v\n", k, v)
          }
        }

        if req.Method == "POST" {
          req.ParseForm()
          fmt.Fprintln(b, "Body:")
          for k, v := range req.Form {
            fmt.Fprintf(b, "  %v: %v\n", k, v)
          }
        }

        return b.String()
      }

      ```

=== "handle_test.go"

      In the unit test, we are calling the function handler directly, and
      checking the response. In a real application, you would replace this
      with your own unit tests confirming your business logic.

      ```go
      package function

      import (
        "context"
        "net/http"
        "net/http/httptest"
        "testing"
      )

      // TestHandle ensures that Handle executes without error and returns the
      // HTTP 200 status code indicating no errors.
      func TestHandle(t *testing.T) {
        var (
          w   = httptest.NewRecorder()
          req = httptest.NewRequest("GET", "http://example.com/test", nil)
          res *http.Response
        )

        Handle(context.Background(), w, req)
        res = w.Result()
        defer res.Body.Close()

        if res.StatusCode != 200 {
          t.Fatalf("unexpected response code: %v", res.StatusCode)
        }
      }
      ```

Now, let's deploy the function to your cluster.
