---
audience: developer
components:
  - functions
  - serving
  - eventing
hide_prev: true
hide_next: true
---

# Next Steps

Choose a next step based on the exercise you completed. Quickstart introduces Services, autoscaling, traffic splitting, and event routing; the local-first Functions exercise introduces editing and invoking a Go HTTP handler. You do not need to complete both before choosing what to do next.

## Continue with a guided exercise

- [Build the Bookstore after the basics](../bookstore/page-0/welcome-knative-bookstore-tutorial.md): process review events with functions and a Sequence, then store accepted reviews. The core route does not require Slack or Camel K. Read its setup requirements before reusing your cluster.
- [Write and run a Go HTTP function locally](about-knative-functions.md): install `func`, edit the generated handler, and recognize its response. No cluster or registry account is required for local execution; deployment is optional.

## Apply or understand what you tried

- [Convert a Kubernetes Deployment to a Knative Service](../serving/convert-deployment-to-knative-service.md).
- **Autoscaling task:** [Set a concurrency target for a Service](../serving/autoscaling/configure-concurrency.md).
- **Autoscaling explanation:** [How concurrency affects autoscaling](../serving/autoscaling/concurrency-behavior.md).
- **Autoscaling reference:** [Concurrency settings](../serving/autoscaling/concurrency.md) and [scale bounds](../serving/autoscaling/scale-bounds.md).
- [Understand Revisions](../serving/revisions/README.md) and the [Serving request flow](../serving/request-flow.md).
- **Functions:** use the [guided follow-on](about-knative-functions.md) to install, create, and run locally, or go directly to [running](../functions/running-functions.md), [deploying](../functions/deploying-functions.md), and [invoking](../functions/invoking-functions.md) your own function.

## Apply or troubleshoot an event route

- **Route matching events:** [Using Triggers](../eventing/triggers/README.md).
- **Configure and verify failure handling:** [Handling Delivery Failure](../eventing/event-delivery.md). This task uses an isolated failure test, not the live Quickstart route.
- **Look up filtering or delivery fields:** [Trigger filtering reference](../eventing/triggers/reference.md) and [Event delivery reference](../eventing/reference/event-delivery.md).
- **No events arrive:** [Events do not reach a subscriber](../eventing/troubleshooting/events-not-delivered.md).
- **Dispatch errors or dead-letter events:** [Events repeatedly fail delivery](../eventing/troubleshooting/delivery-failures.md).

If you created a disposable cluster for Quickstart or optional Functions deployment, keep it only while experimenting; otherwise [clean it up](clean-up.md). A local-only function exercise has no cluster to delete.

**Return to your exercise:** [Quickstart event completion](first-trigger.md) · [Functions local/deployment completion](build-run-deploy-func.md)

**Cleanup, if you created a cluster:** [Clean up the disposable environment](clean-up.md)

[![Knative Slack Link](images/slack-button.svg)](https://slack.cncf.io/){target=_blank}

## :test_tube: Knative samples

Try out some of the following Knative samples:

- [Converting a Kubernetes Service to a Knative Service](../serving/convert-deployment-to-knative-service.md)
- [Knative Serving code samples](../samples/serving.md)
- [Knative Eventing and Event source code samples](../samples/eventing.md)

## :page_with_curl: Explore the Knative docs

See the following guides for documentation specific to your use case:

- [Serving Guide](../serving/README.md)
- [Eventing Guide](../eventing/README.md)

## :book: Knative books

Books to help you understand Knative concepts and get additional examples:

- [Knative in Action](https://www.manning.com/books/knative-in-action)

    ??? question "Want a free digital copy of Knative in Action?"
        VMWare has generously donated access to a free copy of the Knative in Action eBook, [get your copy here!](https://tanzu.vmware.com/content/ebooks/knative-in-action){target=_blank}

- [Knative Cookbook](https://www.oreilly.com/library/view/knative-cookbook/9781492061182/)

## :globe_with_meridians: Other Knative links

Other links to help you get started with Knative:

- [Knative YouTube Channel](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)

## :question: Are we missing something?

We'd love to help you along the next step of your Knative journey. If we're missing something on this page that you feel should be here, please [give us feedback](https://forms.gle/Ab44BUBowmnnJsdW9)!
