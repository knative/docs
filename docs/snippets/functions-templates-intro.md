<!-- Snippet used in the following topics:
- versioned/functions/about-functions.md
-->
Knative Functions provides templates that can be used to create basic functions, by initiating a function project boilerplate when you run a `create` command.

Templates allow you to choose the language and invocation format for your function. The built-in templates in Functions from Knative v1.23.0 provide both `cloudevents` and `http` formats for the languages below. Run `func languages` and `func templates` (or `kn func languages` and `kn func templates`) to check what your installed version and registered repositories actually provide:

- [Node.js](https://github.com/knative/func/blob/main/docs/function-templates/nodejs.md){target=_blank}
- [Python](https://github.com/knative/func/blob/main/docs/function-templates/python.md){target=_blank}
- [Go](https://github.com/knative/func/blob/main/docs/function-templates/golang.md){target=_blank}
- [Quarkus](https://github.com/knative/func/blob/main/docs/function-templates/quarkus.md){target=_blank}
- [Rust](https://github.com/knative/func/blob/main/docs/function-templates/rust.md){target=_blank}
- [Spring Boot](https://github.com/knative/func/blob/main/docs/function-templates/springboot.md){target=_blank}
- [TypeScript](https://github.com/knative/func/blob/main/docs/function-templates/typescript.md){target=_blank}

These links open the upstream `main` guides; select documentation matching the CLI version that generated your project before changing handler signatures. HTTP and CloudEvents templates expose different language-specific APIs. A CloudEvents template does not automatically create a Broker subscription, and support for a language does not imply support by every local builder.
