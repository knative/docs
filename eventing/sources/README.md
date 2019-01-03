# Event Sources

See [Sources.md](Sources.md) for a non-exhaustive list of event sources that work with Knative. The
 canonical, machine-readable version of the data is [sources.yaml](sources.yaml).

### Updating Sources.md

[Sources.md](Sources.md) is a generated file. It should never be created manually.

To update [Sources.md](Sources.md):

1. Update the information in [`sources.yaml`](sources.yaml).

1. Run the generator tool:
    ```shell
    go run eventing/sources/generator/main.go
    ```
