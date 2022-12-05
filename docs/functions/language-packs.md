# Language packs

Language packs can be used to extend Knative Functions to support additional runtimes, function signatures, operating systems, and installed tooling for functions. Language Packs are distributed through Git repositories or as a directory on a disc.

For more information see the [language pack](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md){target=_blank} documentation.

## Using external Git repositories

When creating a new function, a Git repository can be specified as the source
for the template files. The Knative Sandbox maintains a set of [example templates](https://github.com/knative-sandbox/func-tastic){target=_blank} which can be used during project creation.

For example, you can run the following command to use the [`metacontroller`](https://metacontroller.github.io/metacontroller/){target=_blank} template for Node.js:

```{ .console }
func create myfunc -l nodejs -t metacontroller --repository https://github.com/knative-sandbox/func-tastic
```

## Installing language packs locally

Language packs can be installed locally by using the [`func repository`](https://github.com/knative/func/blob/main/docs/reference/func_repository.md){target=_blank} command.

For example, to add the Knative Sandbox example templates, you can run the following command:

```{ .console }
func repository add knative https://github.com/knative-sandbox/func-tastic
```

After the Knative Sandbox example templates are installed, you can use the `metacontroller` template by specifying the `knative` prefix in the `create` command:

```{ .console }
func create -t knative/metacontroller -l nodejs my-controller-function
```
