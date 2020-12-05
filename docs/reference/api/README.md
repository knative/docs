## View the latest release

The reference documentation for the latest release of the Knative is available
at [**www.knative.dev**](https://www.knative.dev/docs/reference/).

### Source files

The API source files are located at:

- [Serving API](./serving.md)
- [Eventing API](./eventing/eventing.md)

## Updating API Reference docs (for Knative maintainers)

The Knative API reference documentation is manually generated using the
[`gen-api-reference-docs.sh`](../../../hack/) tool. If you need to generate a new
version of the API docs for a recent update or for a new release, you can use
the following steps.

To learn more about the tool, see the
[gen-crd-api-reference-docs](https://github.com/ahmetb/gen-crd-api-reference-docs)
reference page.

### Before you begin

You must meet the following requirements to run the `gen-api-reference-docs.sh`
tool:

- You need the following software installed:
  - [`git`](https://git-scm.com/download/)
  - [`go` version 1.11+](https://golang.org/dl/)
- Clone [knative/docs](https://github.com/knative/docs) locally. For example:
  `git clone git@github.com:knative/docs.git`

### Generating the API

To generate a version of the API:

1. Ensure that your `GOPATH` is empty. The `gen-api-reference-docs.sh` script
   will result in the `GOPATH should not be set` error if your `GOPATH` is
   configured. You view the value by running the following command:

   ```
   echo $GOPATH
   ```

   If your `GOPATH` is already configured, temporarily clear the `GOPATH` value
   by running the following command:

   ```
   export GOPATH=""
   ```

1. Locate the commits or tags that correspond to the version of the API that you
   want to generate:

   - [Serving](https://github.com/knative/serving/releases/)
   - [Eventing](https://github.com/knative/eventing/releases/)

1. To run the `gen-api-reference-docs.sh` command from the `hack` directory, you
   specify the commits or tags for each of the corresponding Knative component
   variables (`KNATIVE_[component_name]_COMMIT`):

   ```
   cd hack

   KNATIVE_SERVING_COMMIT=[commit_or_tag] \
   KNATIVE_EVENTING_COMMIT=[commit_or_tag] \
   ./gen-api-reference-docs.sh
   ```

   where `[commit_or_tag]` is the commit or tag in the specific repo that
   represents the version of the API that you want to generate. Also see the
   [example](#example) below.

   **Result**

   The `gen-api-reference-docs.sh` tool generates the API in a `tmp` folder.
   After a successful build, the tool automatically opens that folder in the
   `tmp` directory.

   If the script fails, there are a couple possible causes.

   * If you get the
     `F1116 15:21:23.549503   63473 main.go:129] no API packages found in ./pkg/apis`
     error, check if a new version of the script is available:
      https://github.com/ahmetb/gen-crd-api-reference-docs/tags

      The script is kept up-to-date with changes that go into the Kubernetes API.
      As Knative adds support for those APIs, you might need to make sure the
      corresponding
      [script `gen-crd-api-reference-docs` version](https://github.com/knative/docs/blob/master/hack/gen-api-reference-docs.sh#L26)
      is used.

   * If you get the
     `F0807 13:58:20.621526 168834 main.go:444] type invalid type has kind=Unsupported which is unhandled`
     error, the import target might have moved. There might be other causes for that error but view
     [#2054](https://github.com/knative/docs/pull/2054) (and the linked Issues) for details about how we handled that error
     in the past.

1. Copy the generated API files into the `docs/reference` directory of your
   knative/docs clone.

1. The linter now fails for content with trailing whitespaces. Use a tool of your choice to
   remove all trailing whitespace. For example, search for and remove: `\s+$`

You can now perform the necessary steps to open a PR, complete a review, and
merge the new API files into the appropriate branch of the `knative/docs` repo.
See the [contributor flow](https://github.com/knative/community/blob/master/docs/DOCS-CONTRIBUTING.md) for details
about requesting changes in the `knative/docs` repo.

### Example

To build a set of Knative API docs for v0.18, you can use the `v0.18.0` the tags
from each of the Knative component repositories, like
[Serving v0.18.0](https://github.com/knative/serving/tree/v0.18.0). If you want to
use a commit for Serving v0.18.0, you would use
[850b7c](https://github.com/knative/serving/commit/850b7cca7d7701b052420a030f2308d19938d45e).

Using tags from each repo, you would run the following command to generate the
v0.18.0 API source files:

```
KNATIVE_SERVING_COMMIT=v0.18.0 \
KNATIVE_EVENTING_COMMIT=v0.18.0 \
./gen-api-reference-docs.sh
```
