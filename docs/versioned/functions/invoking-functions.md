---
audience: developer
components:
  - functions
function: how-to
---

# Invoking functions

Send a test request directly to a locally running or deployed function. Direct invocation checks the endpoint and handler; it does not send an event through a Broker or verify a Trigger subscription.

## Prerequisites

- You have [installed the CLI](install-func.md) and opened the initialized function project directory.
- For local testing, [run the function](running-functions.md) and leave it running in another terminal.
- For cluster testing, [deploy the function](deploying-functions.md), check that its Service is Ready, and ensure its URL is reachable from your machine. Complete the [effective kubeconfig/current-context guard](deploying-functions.md#select-and-check-the-cluster) in this invocation shell first. It defines `check_func_context`; `--target=remote` chooses a deployed instance, not a cluster. Confirm that the project's saved deployment namespace is the one you intend to test; setting the shell's `NAMESPACE` variable does not override that project metadata.

## Choose the instance explicitly

Without a target, the CLI prefers a locally running instance over a deployed one. Select the target so that a successful local response cannot be mistaken for a successful deployment check:

=== "func"

    ```bash
    func invoke --target=local
    ```

    Or, to test the deployed instance:

    ```bash
    check_func_context && func invoke --target=remote
    ```

=== "kn func"

    ```bash
    kn func invoke --target=local
    ```

    Or, to test the deployed instance:

    ```bash
    check_func_context && kn func invoke --target=remote
    ```

## Match the request to the handler

By default, the CLI chooses a request format from the function's template metadata. To test an HTTP handler with JSON data:

=== "func"

    ```bash
    func invoke --target=local --format=http \
      --content-type=application/json --data '{"message":"hello"}'
    ```

=== "kn func"

    ```bash
    kn func invoke --target=local --format=http \
      --content-type=application/json --data '{"message":"hello"}'
    ```

For a CloudEvents handler, use `--format=cloudevent` and set the event attributes your handler expects, for example `--type=com.example --source=urn:example:test`. When testing the deployed instance, complete the cluster-selection guard, then prefix the command with `check_func_context &&` and change `--target=local` to `--target=remote`. These requests still go directly to the function, not through a Broker.

The `invoke` section of the [upstream command reference]({{ funcdocs() }}){target=_blank} covers payload files, event extensions, URL targets, and other options. Use reference matching your installed CLI version rather than assuming every template accepts the same test data.

## Verify and diagnose

Compare the response status/body and handler logs with the behavior you expect. Responses vary by language and template. Receiving a response is not by itself proof of correct application behavior.

- **No local instance:** check that `run` is still active, that both terminals use the same project, and that you selected `local`.
- **Remote discovery or connection failure:** check the project's deployment namespace, Service readiness, reported URL, and your network/DNS access. See [Serving application diagnostics](../serving/troubleshooting/debugging-application-issues.md).
- **Handler rejected the request:** check the HTTP/CloudEvents format and required payload against the [template contract](about-functions.md#function-templates) and inspect handler logs.
- **Direct invocation works but Broker events do not arrive:** use the [subscription verification](subscribing-functions.md#verify-event-delivery) and [Eventing diagnostics](../eventing/troubleshooting/events-not-delivered.md).
