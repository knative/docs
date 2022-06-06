# Traffic management

You can manage traffic routing to different Revisions of a Knative Service by modifying the `traffic` spec of the Service resource.

When you create a Knative Service, it does not have any default `traffic` spec settings. By setting the `traffic` spec, you can split traffic over any number of fixed Revisions, or send traffic to the latest Revision by setting `latestRevision: true` in the spec for a Service.

## Using tags to create target URLs

In the following example, the spec defines an attribute called `tag`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
spec:
...
  traffic:
  - percent: 0
    revisionName: example-service-1
    tag: staging
  - percent: 40
    revisionName: example-service-2
  - percent: 60
    revisionName: example-service-3
```

When a `tag` attribute is applied to a Route, an address for the specific traffic target is created.

In this example, you can access the staging target by accessing `staging-<route name>.<namespace>.<domain>`. The targets for `example-service-2` and `example-service-3` can only be accessed using the main route, `<route name>.<namespace>.<domain>`.

When a traffic target is tagged, a new Kubernetes Service is created for that Service, so that other Services can access it within the cluster. From the previous example, a new Kubernetes Service called `staging-<route name>` will be created in the same namespace. This Service has the ability to override the visibility of this specific Route by applying the label `networking.knative.dev/visibility` with value `cluster-local`. See the documentation on [private services](services/private-services.md) for more information about how to restrict visibility on specific Routes.

## Traffic routing examples

The following example shows a `traffic` spec where 100% of traffic is routed to the `latestRevision` of the Service. Under `status` you can see the name of the latest Revision that `latestRevision` was resolved to:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
spec:
...
  traffic:
  - latestRevision: true
    percent: 100
status:
  ...
  traffic:
  - percent: 100
    revisionName: example-service-1
```

The following example shows a `traffic` spec where 100% of traffic is routed to the `current` Revision, and the name of that Revision is specified as `example-service-1`. The latest ready Revision is kept available, even though no traffic is being routed to it:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
spec:
...
  traffic:
  - tag: current
    revisionName: example-service-1
    percent: 100
  - tag: latest
    latestRevision: true
    percent: 0
```

The following example shows how the list of Revisions in the `traffic` spec can be extended so that traffic is split between multiple Revisions. This example sends 50% of traffic to the `current` Revision, `example-service-1`, and 50% of traffic to the `candidate` Revision, `example-service-2`:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: example-service
  namespace: default
spec:
...
  traffic:
  - tag: current
    revisionName: example-service-1
    percent: 50
  - tag: candidate
    revisionName: example-service-2
    percent: 50
  - tag: latest
    latestRevision: true
    percent: 0
```

## Routing and managing traffic by using the Knative CLI

You can use the following `kn` CLI command to split traffic between revisions:

```bash
kn service update <service-name> --traffic <revision-name>=<percent>
```

Where:

- `<service-name>` is the name of the Knative Service that you are configuring traffic routing for.
- `<revision-name>` is the name of the revision that you want to configure to receive a percentage of traffic.
- `<percent>` is the percentage of traffic that you want to send to the revision specified by `<revision-name>`.

For example, to split traffic for a Service named `example`, by sending 80% of traffic to the Revision `green` and 20% of traffic to the Revision `blue`, you could run the following command:

```bash
kn service update example-service --traffic green=80 --traffic blue=20
```

It is also possible to add tags to Revisions and then split traffic according to the tags you have set:

```bash
kn service update example --tag revision-0001=green --tag @latest=blue
```

The `@latest` tag means that `blue` resolves to the latest Revision of the Service. The following example sends 80% of traffic to the latest Revision and 20% to a Revision named `v1`.

```bash
kn service update example-service --traffic @latest=80 --traffic v1=20
```

## Routing and managing traffic with blue/green deployment

You can safely reroute traffic from a live version of an application to a new version by using a [blue/green deployment strategy](https://en.wikipedia.org/wiki/Blue-green_deployment).

### Procedure

1. Create and deploy an app as a Knative Service.
1. Find the name of the first Revision that was created when you deployed the Service, by running the command:

    ```bash
    kubectl get configurations <service-name> -o=jsonpath='{.status.latestCreatedRevisionName}'
    ```

    Where `<service-name>` is the name of the Service that you have deployed.

1. Define a Route to send inbound traffic to the Revision.

    ***Example Route***
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Route
    metadata:
      name: <route-name>
      namespace: default
    spec:
      traffic:
        - revisionName: <first-revision-name>
          percent: 100 # All traffic goes to this revision
    ```

    Where;

    - `<route-name>` is the name you choose for your route.
    - `<first-revision-name>` is the name of the initial Revision from the previous step.

1. Verify that you can view your app at the URL output you get from using the following command:


    ```bash
    kubectl get route <route-name>
    ```

    Where `<route-name>` is the name of the Route you created in the previous step.

1. Deploy a second Revision of your app by modifying at least one field in the `template` spec of the Service resource. For example, you can modify the `image` of the Service, or an `env` environment variable.

1. Redeploy the Service by applying the updated Service resource. You can do this by applying the Service YAML file or by using the `kn service update` command if you have installed the `kn` CLI.

1. Find the name of the second, latest Revision that was created when you redeployed the Service, by running the command:

    ```bash
    kubectl get configurations <service-name> -o=jsonpath='{.status.latestCreatedRevisionName}'
    ```

    Where `<service-name>` is the name of the Service that you have redeployed.

    At this point, both the first and second Revisions of the Service are deployed and running.

1. Update your existing Route to create a new, test endpoint for the second Revision, while still sending all other traffic to the first Revision.

    ***Example of updated Route***
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Route
    metadata:
      name: <route-name>
      namespace: default
    spec:
      traffic:
        - revisionName: <first-revision-name>
          percent: 100 # All traffic is still being routed to the first revision
        - revisionName: <second-revision-name>
          percent: 0 # 0% of traffic routed to the second revision
          tag: v2 # A named route
    ```

    Once you redeploy this Route by reapplying the YAML resource, the second Revision of the app is now staged.

    No traffic is routed to the second Revision at the main URL, and Knative creates a new Route named `v2` for testing the newly deployed Revision.

1. Get the URL of the new Route for the second Revision, by running the command:

    ```bash
    kubectl get route <route-name> --output jsonpath="{.status.traffic[*].url}"
    ```

    You can use this URL to validate that the new version of the app is behaving as expected before you route any traffic to it.

1. Update your existing Route resource again, so that 50% of traffic is being sent to the first Revision, and 50% is being sent to the second Revision:

    ***Example of updated Route***
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Route
    metadata:
      name: <route-name>
      namespace: default
    spec:
      traffic:
        - revisionName: <first-revision-name>
          percent: 50
        - revisionName: <second-revision-name>
          percent: 50
          tag: v2
    ```

1. Once you are ready to route all traffic to the new version of the app, update the Route again to send 100% of traffic to the second Revision:

    ***Example of updated Route***
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Route
    metadata:
      name: <route-name>
      namespace: default
    spec:
      traffic:
        - revisionName: <first-revision-name>
          percent: 0
        - revisionName: <second-revision-name>
          percent: 100
          tag: v2
    ```

    !!! tip
        You can remove the first Revision instead of setting it to 0% of traffic if you do not plan to roll back the Revision. Non-routeable Revision objects are then garbage-collected.
    <!--TODO: ADD GARBAGE COLLECTION DOCS-->

1. Visit the URL of the first Revision to verify that no more traffic is being sent to the old version of the app.

<!-- TODO: Add docs about autoscaling and named routes, e.g. explain v2 properly above-->
