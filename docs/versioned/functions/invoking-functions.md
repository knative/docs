# Invoking functions

You can use the `func invoke` command to send a test request to invoke a
function either locally or on your Knative cluster.

This command can be used to test that a function is working and able to receive HTTP requests and CloudEvents correctly.

If your function is running locally, `func invoke` sends a test request to the local instance.

You can use the `func invoke` command to send test data to your function with the `--data` flag, as well as other options to simulate different types of requests. See the [func invoke](https://github.com/knative/func/blob/main/docs/reference/func_invoke.md){target=_blank} documentation for more information.
