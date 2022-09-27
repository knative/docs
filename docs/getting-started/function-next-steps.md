# Next Steps with Knative Functions

Knative Functions are meant to get developers started quickly with Knative.
Functions are a great way to learn about Knative, and help you understand
how to use Knative Serving and Eventing resources. Now that you have created
your first Function, and followed the Serving and Eventing tutorials, you
are ready to learn more about the Function lifecycle and its integration
with Knative Serving and Eventing.

## Local Builds and Testing

In the [Creating a Knative Function](./creating-function.md) tutorial, you
learned how to create and deploy a Knative Function. During the deployment,
your function source code was built into an OCI container image before being
pushed to a container registry. This build step can be performed directly
using the `func build` command to simply build and store the image locally.
The function can then be run and tested locally as the container image using
the `func run` command. See the
[`func build`](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func_build.md)
and
[`func run`](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func_run.md)
command reference for more information.

### Invoking Functions

You can use the `func invoke` CLI command to send a test request to invoke a
function either locally or on your Knative cluster. This command can be used
to test that a function is working and able to receive HTTP requests and events
correctly. If your function is running locally, `func invoke` will send a test
request to the local instance. You can use the `func invoke` command to send
test data to your function with the `--data` flag, as well as other options
to simulate different types of requests. See the
[func invoke command reference](https://github.com/knative-sandbox/kn-plugin-func/blob/main/docs/reference/func_invoke.md)
for more information.
