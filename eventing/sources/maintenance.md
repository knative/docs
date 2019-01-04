# Event Sources

The canonical, machine-readable list of sources is [sources.yaml](sources.yaml). That is used to
generate the [README.md](README.md).


### Updating README.md

[README.md](README.md) is a generated file. It should never be changed manually.

To update [README.md](README.md):

1. Update the information in [`sources.yaml`](sources.yaml).

1. Run the generator tool:
    ```shell
    go run eventing/sources/generator/main.go
    ```
