# Creating a Knative Function

Knative Functions provide a programming model that leverages the Knative
Serving and eventing APIs to provide a quick and easy way for developers
to deploy their first Knative applications. Function lifecycle management
includes creating, building, and deploying a function. Optionally, you can
also test a deployed function by invoking it locally or on a cluster.
You can do all of these operations using the `func` command line interface.

In this tutorial, you will create, build and deploy a Knative Function
that responds to CloudEvents emitted by a Ping Source. Supported languages
for Knative Functions include Go, JavaScript, TypeScript, Java and Rust.
In this tutorial, you will use Go.

=== "func"

    Create the function by running the command:

    ```bash
    func create -l go -t cloudevents hello
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
        Created go function in hello
        ```
