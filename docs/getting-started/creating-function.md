# Creating a Knative Function

Knative Functions provide a programming model that leverages the Knative
Serving and Eventing APIs to provide a quick and easy way for developers
to deploy their first Knative applications. You don't need to know anything
about Knative or even Kubernetes resources to create and deploy your first
project. Deploying a Knative Function is the easiest way to get started with
Knative.

While the `func` CLI has been optimized for the simplest path to deploying
a function, it is also flexible enough to support more advanced use cases.

Function lifecycle management includes creating, building, and deploying a
function. Optionally, you can also test a deployed function by invoking it
locally or on a cluster. You can do all of these operations using the `func`
command line interface.

In this tutorial, we will start simple. You will create and deploy a Knative
Function that responds to HTTP requests. Supported languages for Knative
Functions include Go, JavaScript, TypeScript, Java and Rust. In this tutorial,
you will use Go.

=== "func"

    Create the function by running the command:

    ```bash
    func create -l go hello
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
        Created go function in hello
        ```
