---
audience: developer
components:
  - functions
  - serving
  - eventing
function: tutorial
hide_prev: true
hide_next: true
---

<span id="next-steps"></span><span id="continue-learning"></span>

# Next steps and cleanup

<span id="explore-the-knative-docs"></span><span id="work-on-your-own-project"></span>

## Build your own application

- **Serving:** [deploy your own container](../serving/services/creating-services.md)
  or [configure a custom domain](../serving/services/custom-domains.md).
- **Functions:** [build a function image](../functions/building-functions.md)
  or [deploy your own function](../functions/deploying-functions.md).
- **Eventing:** [create a Broker](../eventing/brokers/create-broker.md)
  or [route events using Triggers](../eventing/triggers/README.md).
- **Platform operations:** [install and manage Knative](../admin/admin-overview.md),
  or browse [CLI tools](../client/README.md) and API references ([Serving](../serving/reference/serving-api.md),
  [Eventing](../eventing/reference/eventing-api.md)).

<span id="knative-samples"></span><span id="build-a-larger-application"></span>

## Try Bookstore

Build the [Bookstore sample application](../bookstore/page-0/welcome-knative-bookstore-tutorial.md)
to combine Functions, Serving, and Eventing. Its
[environment setup](../bookstore/page-0.5/environment-setup.md) reuses your
learning cluster with local port-forwarding. You can also browse
[code samples](../samples/README.md).

<span id="clean-up"></span><span id="finished-experimenting"></span>

## Clean up

Keep your learning cluster if you want to try another track. Clean up only the
resources you created:

??? note "Local Functions"

    Press ++ctrl+c++ in the `func run` terminal. Your source files remain on
    disk. To remove the local tutorial image after stopping the function:

    ```bash
    docker image rm localhost/hello-function:latest
    ```

??? note "Disposable learning cluster"

    Deleting the `knative` kind cluster removes **all applications and data in
    that cluster** across every tutorial, without touching other clusters on
    your machine:

    ```bash
    kind delete cluster --name knative
    ```

    Do not run this against a cluster used for other work. If you have other
    clusters, switch back to your usual `kubectl` context afterward.

    If you used the older minikube Quickstart, delete that profile with
    `minikube delete -p knative`.

??? note "Published image (optional deployment)"

    Deleting the cluster does not remove images pushed to your container
    registry. Delete the `hello-function` tutorial image from your registry if
    you no longer need it.

<span id="ask-for-help"></span><span id="knative-books"></span><span id="other-knative-links"></span><span id="are-we-missing-something"></span>

## Get help

[Join the Knative community](https://knative.dev/community/) and share the
tutorial page, failing command, and error message. Never share kubeconfig,
passwords, or access tokens.
