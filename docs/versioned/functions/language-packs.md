---
audience: developer
components:
  - functions
function: how-to
hide_prev: true
hide_next: true
---

# Templates and runtimes

Knative Functions includes built-in language runtimes and templates, and lets
you pull custom templates from Git repositories via language packs.

## Choose a runtime

Pass `-l <language>` to `func create`. Built-in runtimes:

| Runtime | `-l` value |
| --- | --- |
| Go | `go` |
| Node.js | `node` |
| TypeScript | `typescript` |
| Python | `python` |
| Quarkus (Java) | `quarkus` |
| Spring Boot (Java) | `springboot` |
| Rust | `rust` |

## Choose HTTP or CloudEvents

Pass `-t <template>` to `func create` (default `http`):

- **`http`** — handles standard HTTP requests and responses.
- **`cloudevents`** — receives and optionally returns CloudEvents; use this
  when connecting a function to Knative Eventing or Kafka.

```bash
func create -l python -t cloudevents my-event-fn
```

## Use an external repository

To scaffold a function from a remote Git template repository without installing
it locally, pass `--repository`:

```bash
func create -l go \
  --template <template-name> \
  --repository <git-repo-url> \
  my-function
```

Verify the generated `my-function/` directory contains `func.yaml` and the
expected template files.

## Installed repositories { #manage-installed-repositories }

Install a trusted template repository locally with `func repository` so you can
reuse its templates by name:

1. Add the repository and verify it appears in the list:

    ```bash
    func repository add my-pack <git-repo-url>
    func repository list
    ```

    The output lists `default` alongside `my-pack`.

1. Create a function using `<repo-name>/<template-name>`:

    ```bash
    func create -l go -t my-pack/<template-name> my-function
    ```

1. Rename or remove installed repositories when needed:

    ```bash
    func repository rename my-pack renamed-pack
    func repository remove renamed-pack
    ```

For all repository flags, see the
[`func repository` reference](https://github.com/knative/func/blob/main/docs/reference/func_repository.md){target=_blank}.
To author your own language pack, see the
[language pack contract](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md){target=_blank}.
