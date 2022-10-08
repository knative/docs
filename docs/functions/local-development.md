# Next Steps with Knative Functions

Knative Functions are meant to get developers started quickly with Knative.
Functions are a great way to learn about Knative, and help you understand
how to use Knative Serving and Eventing resources. Now that you have created
your first Function, and followed the Serving and Eventing tutorials, you
are ready to learn more about the Function lifecycle and its integration
with Knative Serving and Eventing.

## Local Builds

In the [Creating a Knative Function](../getting-started/creating-function.md) tutorial, you
learned how to create and deploy a Knative Function. During the deployment,
your function source code was built into an OCI container image before being
pushed to a container registry. This build step can be performed directly
using the `func build` command to simply build and store the image locally.
The function can then be run and tested locally as the container image using
the `func run` command. See the
[`func build`](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func_build.md){target=_blank}
and
[`func run`](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func_run.md){target=_blank}
command reference for more information.

## On Cluster Builds

In the [Creating a Knative Function](../getting-started/creating-function.md) tutorial, when
you deployed your function, the build step was performed on your local computer.
This may not always be ideal, if you are in a situation where you do not have
a local Docker daemon running, or in a CI/CD pipeline. In this case a function
can be built on the cluster using the `func deploy --remote` command. This command
requires your function to exist in a Git repository. When running the command
for the first time, you will need to specify the Git URL for your function. For
example:

=== "func"

    ```{ .console }
    func deploy --remote --registry <registry> --git-url <git-url> -p hello
    ```

=== "kn func"

    ```{ .console }
    kn func deploy --remote --registry <registry> --git-url <git-url> -p hello
    ```

As with many `func` commands, after you have specified the Git URL for your
function once, you can omit it in subsequent commands.

To perform an on-cluster build, you will need to configure your cluster with
Tekton Pipelines. To learn more about building on your cluster, and those
requirements, see the
[On Cluster Build](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/on_cluster_build.md){target=_blank}
reference in the `func` documentation.

## Invoking Functions

You can use the `func invoke` CLI command to send a test request to invoke a
function either locally or on your Knative cluster. This command can be used
to test that a function is working and able to receive HTTP requests and
CloudEvents correctly. If your function is running locally, `func invoke`
will send a test request to the local instance. You can use the `func invoke`
command to send test data to your function with the `--data` flag, as well as
other options to simulate different types of requests. See the
[func invoke command reference](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func_invoke.md){target=_blank}
for more information.
