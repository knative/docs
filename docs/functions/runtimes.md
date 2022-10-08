Knative Functions provides templates that can be used to create basic functions.
A template initiates the function project boilerplate when you run the
`func create` command. Templates allow you to choose the language and invocation
format for your function. The following templates are available with both CloudEvent
and HTTP invocation formats:

- [Node.js](https://github.com/knative/func/blob/main/docs/function-developers/nodejs.md)
- [Python](https://github.com/knative/func/blob/main/docs/function-developers/python.md)
- [Go](https://github.com/knative/func/blob/main/docs/function-developers/golang.md)
- [Quarkus](https://github.com/knative/func/blob/main/docs/function-developers/quarkus.md)
- [Rust](https://github.com/knative/func/blob/main/docs/function-developers/rust.md)
- [TypeScript](https://github.com/knative/func/blob/main/docs/function-developers/typescript.md)

These embedded templates are minimal by design. To make use of more complex
initial function boilerplate, or to define runtime environments with
arbitrarily complex requirements, the templates system is fully pluggable.

## Language Packs

Language Packs are the mechanism by which Knative Functions can be extended to
support additional runtimes, function signatures, even operating systems and
installed tooling for a function. Language Packs are typically distributed via
Git repositories but may also simply exist as a directory on a disc.

### External Git Repositories

When creating a new function, a Git repository can be specified as the source
for the template files.  For example, the Knative Sandbox maintains a set of
[example templates](https://github.com/knative-sandbox/func-tastic) which can be
used during project creation.

To use the [`metacontroller`](https://metacontroller.github.io/metacontroller/){target=_blank}
template for Node.js from this language pack you can run:

```{ .console }
func create myfunc -l nodejs -t metacontroller --repository https://github.com/knative-sandbox/func-tastic
```

### Locally Installing a Language Pack

Language Packs can also be installed locally using the
[`func repository`](https://github.com/knative/func/blob/main/docs/reference/func_repository.md){target=_blank}
command. To add the Knative Sandbox example templates, you can run:

```{ .console }
func repository add knative https://github.com/knative-sandbox/func-tastic
```

Once installed, the `metacontroller` template can be used by specifying the `knative` prefix
in the `create` command:

```{ .console }
func create -t knative/metacontroller -l nodejs my-controller-function
```

A Language Pack can support additional function signatures and can fully customize
the environment of the final running function.
For more information see the
[Language Pack Guide](https://github.com/knative/func/blob/main/docs/language-pack-providers/language-pack-contract.md){target=_blank}.
