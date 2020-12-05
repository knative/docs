GitLab Source example shows how to wire GitLab events for consumption by a
Knative Service.

## Gitlab source deployment

### Prerequisites

You will need:

1. An internet-accessible Kubernetes cluster with Knative Serving installed.
   Follow the [installation instructions](../../../install/README.md) if you
   need to create one.
1. Ensure Knative Serving is
   [configured with a domain name](../../../serving/using-a-custom-domain.md)
   that allows GitLab to call into the cluster.
1. If you're using GKE, you'll also want to
   [assign a static IP address](../../../serving/gke-assigning-static-ip-address.md).
1. Install [Knative Eventing](../../../eventing).

### Install GitLab Event Source

GitLab Event source lives in the [knative/eventing-contrib](https://github.com/knative/eventing-contrib). Head to the releases page, find the latest release with `gitlab.yaml`
artifact and replace the `<RELEASE>` with version tag:

```shell
kubectl apply -f https://github.com/knative/eventing-contrib/releases/download/<RELEASE>/gitlab.yaml
```

Check that the manager is running:

```shell
kubectl -n knative-sources get pods --selector control-plane=gitlab-controller-manager
```

With the controller running you can now move on to a user persona and setup a
GitLab webhook as well as a function that will consume GitLab events.

## Using the GitLab Event Source

You are now ready to use the Event Source and trigger functions based on GitLab
projects events.

We will:

- Create a Knative service which will receive the events. To keep things simple
  this service will simply dump the events to `stdout`, this is the so-called:
  _event_display_
- Create a GitLab access token and a random secret token used to secure the
  webhooks
- Create the event source by posting a GitLab source object manifest to
  Kubernetes

### Create a Knative Service

The `event-display.yaml` file shown below defines the basic service which will
receive events from the GitLab source.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: gitlab-event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
```

Create the service:

```shell
kubectl -n default apply -f event-display.yaml
```

### Create GitLab Tokens

1. Create a
   [personal access token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)
   which the GitLab source will use to register webhooks with the GitLab API.
   The token must have an "api" access scope in order to create repository
   webhooks. Also decide on a secret token that your source will use to
   authenticate the incoming webhooks from GitLab.

1. Update a secret values in `secret.yaml` defined below:

   `accessToken` is the personal access token created in step 1 and
   `secretToken` is any token of your choosing.

   Hint: you can generate a random _secretToken_ with:

   ```shell
   head -c 8 /dev/urandom | base64
   ```

   `secret.yaml`:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: gitlabsecret
   type: Opaque
   stringData:
     accessToken: <personal_access_token_value>
     secretToken: <random_string>
   ```

1. Create the secret using `kubectl`.

   ```shell
   kubectl -n default apply -f secret.yaml
   ```

### Create Event Source for GitLab Events

1. In order to receive GitLab events, you have to create a concrete Event Source
   for a specific namespace. Replace the `projectUrl` value in the
   `gitlabsource.yaml` file with your GitLab project URL, for example
   `https://gitlab.com/knative-examples/functions`.

   `gitlabsource.yaml`:

   ```yaml
   apiVersion: sources.knative.dev/v1alpha1
   kind: GitLabSource
   metadata:
     name: gitlabsource-sample
   spec:
     eventTypes:
       - push_events
       - issues_events
     projectUrl: <project url>
     accessToken:
       secretKeyRef:
         name: gitlabsecret
         key: accessToken
     secretToken:
       secretKeyRef:
         name: gitlabsecret
         key: secretToken
     sink:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: gitlab-event-display
   ```

1. Apply the yaml file using `kubectl`:

   ```shell
   kubectl -n default apply -f gitlabsource.yaml
   ```

### Verify

Verify that GitLab webhook was created by looking at the list of webhooks under
**Settings >> Integrations** in your GitLab project. A hook should be listed
that points to your Knative cluster.

Create a push event and check the logs of the Pod backing the
`gitlab-event-display` knative service. You will see the event:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.sources.gitlabsource.Push Hook
  source: https://gitlab.com/<user>/<project>
  id: f83c080f-c2af-48ff-8d8b-fd5b21c5938e
  time: 2020-03-12T11:08:41.414572482Z
  datacontenttype: application/json
Data,
  {
   <Event payload>
  }
```

### Cleanup

You can remove the GitLab webhook by deleting the GitLab source:

```shell
kubectl --namespace default delete --filename gitlabsource.yaml
```

Similarly, you can remove the Service and Secret via:

```shell
kubectl --namespace default delete --filename event-display.yaml
kubectl --namespace default delete --filename secret.yaml

```
