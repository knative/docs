# Creating code samples

There are currently two general types of content that focus on code samples,
either internal contributor content, or external-facing user content.

## Contributor-focused content

- _Documentation_: Includes content that is component specific and relevant only
  to contributors of a given component. Contributor focused documentation is
  located in the corresponding `docs` folder of that component's repository. For
  example, if you contribute code to the Knative Serving component, you might
  need to add contributor focused information into the `docs` folder of the
  [knative/serving repo](https://github.com/knative/serving/tree/main/docs/).

- _Code samples_: Includes contributor related code or samples. Code or samples
  that are contributor focused also belong in their corresponding component's
  repo. For example, Eventing specific test code is located in the
  [knative/eventing tests](https://github.com/knative/eventing/tree/main/test)
  folder.

## User-focused content

- _Documentation_: Content for developers or administrators using Knative. This
  documentation belongs in the
  [`knative/docs` repo](https://github.com/knative/docs). All content in
  `knative/docs` is published to the [Knative website](https://knative.dev).

- _Code samples_: Includes user-facing code samples and their accompanying
  step-by-step instructions. Code samples add a particular burden because they
  sometimes get out of date quickly; as such, not all code samples may be
  suitable for the docs repo.

  - **Knative owned and maintained**: Includes code samples that are actively
    maintained and e2e tested. To ensure content is current and balance
    available resources, only the code samples that meet the following
    requirements are located in the `code-samples/serving` and `code-samples/eventing` folders of the
    `knative/docs` repo:

    - _Actively maintained_ - The code sample has an active Knative team member
      who has committed to regular maintenance of that content and ensures that
      the code is updated and working for every product release.

    - _Receives regular traffic_ - To avoid hosting and maintaining unused or
      stale content, if code samples are not being viewed and fail to receive
      attention or use, those samples will be moved into the
      “[community maintained](https://github.com/knative/docs/tree/main/code-samples/community)”
      set of samples.

  - **Community owned and maintained samples**: For sample code which doesn't
    meet the mentioned criteria, put the code in a separate repository and link to it [from this page](../../docs/samples/README.md). These samples might not receive regular maintenance. It is possible that a
    sample is no longer current and is not actively maintained by its original
    author. While we encourage a contributor to maintain their content, we
    acknowledge that it's not always possible for certain reasons, for example
    other commitments and time constraints.

While a sample might be out of date, it could still provide assistance and help
you get up-and-running with certain use-cases. If you find that something is not
right or contains outdated info, open an
[Issue](https://github.com/knative/docs/issues/new). The sample might be fixed
if bandwidth or available resource exists, or the sample might be taken down and
archived into the last release branch where it worked.
