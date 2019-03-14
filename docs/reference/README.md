# Knative API Reference documentation

- [Serving API](serving.md)
- [Build API](build.md)
- [Eventing API](eventing/eventing.md)
- [Event Sources API](eventing/eventing-sources.md)

Note: The Knative API reference documentation is manually generated using the
[gen-api-reference-docs.sh](../../hack/) tool. After cloning the Knative/docs
repo, you must open the `gen-api-reference-docs.sh` script locally and specify
the commit/tag for each of the Knative repos before running that script.
To build a specific version of the API, you must specify the corresponding
commit or tag numbers across each of the Knative repos.
For example, to build a set of Knative API docs for v0.3, you can the tag
numbers in each repo. So for
[Serving v0.3.0](https://github.com/knative/serving/tree/v0.3.0) you specify
`KNATIVE_SERVING_COMMIT="v0.3.0"`, and so on for each of the Build, Eventing,
and Eventing Sources repos.
