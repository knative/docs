<!-- Snippet used in the following topics:
- /docs/functions/README.md
-->
Knative Functions provides built in templates that can be used to create basic functions, by initiating a function project boilerplate when you run a `create` command.

Templates allow you to choose the language and invocation format for your function. The following templates are available with both CloudEvent and HTTP invocation formats:

- [Node.js](https://github.com/knative/func/blob/main/docs/function-developers/nodejs.md){target=_blank}
- [Python](https://github.com/knative/func/blob/main/docs/function-developers/python.md){target=_blank}
- [Go](https://github.com/knative/func/blob/main/docs/function-developers/golang.md){target=_blank}
- [Quarkus](https://github.com/knative/func/blob/main/docs/function-developers/quarkus.md){target=_blank}
- [Rust](https://github.com/knative/func/blob/main/docs/function-developers/rust.md){target=_blank}
- [TypeScript](https://github.com/knative/func/blob/main/docs/function-developers/typescript.md){target=_blank}

The function templates that are included with the `func` binary are considered the
"built-in" or default templates. These templates can be extended by installing
additional templates from a Git repository. These additional templates are called
[Language Packs](/docs/functions/language-packs/).