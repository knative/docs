---
title: "Adding the event source to eventing-contrib"
linkTitle: "Adding to eventing-contrib"
weight: 10
type: "docs"
---

If you would like to contribute Knative's [`eventing-contrib`](https://github.com/knative/eventing-contrib/), as a starting point you can
have a look at different sources there, such as
[`KafkaSource`](https://github.com/knative/eventing-contrib/tree/master/kafka/source),
[`GithubSource`](https://github.com/knative/eventing-contrib/tree/master/github) and
[`AWSSQSSource`](https://github.com/knative/eventing-contrib/tree/master/awssqs).

To generate and inject `clientset`, `cache`, `informers`, and `listers`, ensure that the specific source subdirectories has been added to the injection portion of the
[`hack/update-codegen.sh`](https://github.com/knative/eventing-contrib/blob/master/hack/update-codegen.sh) script.

```patch

# Sources
+API_DIRS_SOURCES=(camel/source/pkg awssqs/pkg couchdb/source/pkg prometheus/pkg YourSourceHere/pkg)
-API_DIRS_SOURCES=(camel/source/pkg awssqs/pkg couchdb/source/pkg prometheus/pkg)

# Knative Injection

chmod +x ${KNATIVE_CODEGEN_PKG}/hack/generate-knative.sh
${KNATIVE_CODEGEN_PKG}/hack/generate-knative.sh "injection" \
-  knative.dev/sample-source/pkg/client knative.dev/sample-source/pkg/apis \
-  "samples:v1alpha1" \
+  knative.dev/your-source/pkg/client knative.dev/your-source/pkg/apis \
+  "your-name:v1alpha1" \
  --go-header-file ${REPO_ROOT}/hack/boilerplate/boilerplate.go.txt

```
and
```patch
  -i knative.dev/eventing-contrib/github/pkg/apis \
- -i knative.dev/eventing-contrib/gitlab/pkg/apis
+ -i knative.dev/eventing-contrib/gitlab/pkg/apis \
+ -i knative.dev/eventing-contrib/YourSourceHere/pkg/apis

```
