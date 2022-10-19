Language Packs are the mechanism by which Knative Functions can be extended to
support additional runtimes, function signatures, even operating systems and
installed tooling for a function. Language Packs are typically distributed via
Git repositories but may also simply exist as a directory on a disc.

## Language Packs from Git Repositories

When creating a new function, a Git repository can be specified as the source
for the template files. For example, the Knative Sandbox maintains a set of
example templates which can be used during project creation.

To use the [`metacontroller`](https://metacontroller.github.io/metacontroller){target=_blank}
template for Node.js from the Knative Sandbox language pack you can run:

=== "`func` CLI"

    ```console
    func create myfunc -l nodejs -t metacontroller --repository https://github.com/knative-sandbox/func-tastic
    ```

=== "`kn func` plugin"

    ```console
    kn func create myfunc -l nodejs -t metacontroller --repository https://github.com/knative-sandbox/func-tastic
    ```

!!! Success "Expected output"

    ```{ .console .no-copy }
    Created nodejs function in myfunc
    ```

## Installing Language Packs locally

Language Packs can also be installed locally using the
[`func repository`](https://github.com/knative/func/blob/main/docs/reference/func_repository.md){target=_blank}
command. To add the Knative Sandbox example templates, you can run:

=== "`func` CLI"

    ```console
    func repository add knative https://github.com/knative-sandbox/func-tastic
    ```

=== "`kn func` plugin"

    ```console
    kn func repository add knative https://github.com/knative-sandbox/func-tastic
    ```

!!! Success "Expected output"

    ```{ .console .no-copy }
    Repository 'knative' added
    ```

Once added, you can see the available templates using the `func templates` command:

=== "`func` CLI"

    ```console
    func templates
    ```

=== "`kn func` plugin"

    ```console
    kn func templates
    ```

!!! Success "Expected output"

    ```{ .console .no-copy }
      LANGUAGE     TEMPLATE
      go           cloudevents
      go           http
      go           knative/improve
      go           knative/uppercase
      node         cloudevents
      node         http
      nodejs       knative/metacontroller
      python       cloudevents
      python       http
      python       knative/numpy
      quarkus      cloudevents
      quarkus      http
      rust         cloudevents
      rust         http
      springboot   cloudevents
      springboot   http
      springboot   knative/uppercase
      typescript   cloudevents
      typescript   http
    ```

After you have added a remote language pack, you can use the templates from the
repository when creating a new function. To use the
[`metacontroller`](https://metacontroller.github.io/metacontroller){target=_blank}
template for Node.js:

=== "`func` CLI"

    ```console
    func create -l nodejs -t knative/metacontroller myfunc
    ```

=== "`kn func` plugin"

    ```console
    kn func create -l nodejs -t knative/metacontroller myfunc
    ```

!!! Success "Expected output"

    ```{ .console .no-copy }
    Created nodejs function in myfunc
    ```
