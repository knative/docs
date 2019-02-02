
A handler written in Go that demonstrates interacting with GitHub through a
webhook.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../../install/)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- An account on [GitHub](https://github.com) with read/write access to a
  repository.

## Build the sample code

1. Use Docker to build a container image for this service. Replace `username`
   with your Docker Hub username in the following commands.

```shell
export DOCKER_HUB_USERNAME=username

# Build the container, run from the project folder
docker build -t ${DOCKER_HUB_USERNAME}/gitwebhook-go .

# Push the container to the registry
docker push ${DOCKER_HUB_USERNAME}/gitwebhook-go
```

1. Create a secret that holds two values from GitHub, a personal access token
   used to make API requests to GitHub, and a webhook secret, used to validate
   incoming requests.

   1. Follow the GitHub instructions to
      [create a personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).
      Ensure to grant the `repo` permission to give `read/write` access to the
      personal access token.
   1. Base64 encode the access token:

      ```shell
      $ echo -n "45d382d4a9a93c453fb7c8adc109121e7c29fa3ca" | base64
      NDVkMzgyZDRhOWE5M2M0NTNmYjdjOGFkYzEwOTEyMWU3YzI5ZmEzY2E=
      ```

   1. Copy the encoded access token into `github-secret.yaml` next to
      `personalAccessToken:`.
   1. Create a webhook secert value unique to this sample, base64 encode it, and
      copy it into `github-secret.yaml` next to `webhookSecret:`:

      ```shell
      $ echo -n "mygithubwebhooksecret" | base64
      bXlnaXRodWJ3ZWJob29rc2VjcmV0
      ```

   1. Apply the secret to your cluster:

      ```shell
      kubectl apply --filename github-secret.yaml
      ```

1. Next, update the `service.yaml` file in the project to reference the tagged
   image from step 1.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: gitwebhook
  namespace: default
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            # Replace {DOCKER_HUB_USERNAME} with your actual docker hub username
            image: docker.io/{DOCKER_HUB_USERNAME}/gitwebhook-go
            env:
              - name: SECRET_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: githubsecret
                    key: secretToken
              - name: ACCESS_TOKEN
                valueFrom:
                  secretKeyRef:
                    name: githubsecret
                    key: accessToken
```

1. Use `kubectl` to apply the `service.yaml` file.

```shell
$ kubectl apply --filename service.yaml
service "gitwebhook" created
```

1. Finally, once the service is running, create the webhook from your GitHub
   repo to the URL for this service. For this to work properly you will need to
   [configure a custom domain](../../using-a-custom-domain/)
   and
   [assign a static IP address](../../gke-assigning-static-ip-address/).

   1. Retrieve the hostname for this service, using the following command:

      ```shell
      $ kubectl get ksvc gitwebhook \
         --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
      NAME                DOMAIN
      gitwebhook          gitwebhook.default.example.com
      ```

   1. Browse on GitHub to the repository where you want to create a webhook.
   1. Click **Settings**, then **Webhooks**, then **Add webhook**.
   1. Enter the **Payload URL** as `http://{DOMAIN}`, with the value of DOMAIN
      listed above.
   1. Set the **Content type** to `application/json`.
   1. Enter the **Secret** value to be the same as the original base used for
      `webhookSecret` above (the original value, not the base64 encoded value).
   1. Select **Disable** under SSL Validation, unless you've
      [enabled SSL](../../using-an-ssl-cert/).
   1. Click **Add webhook** to create the webhook.

## Exploring

Once deployed, you can inspect the created resources with `kubectl` commands:

```shell
# This will show the Knative service that we created:
kubectl get ksvc --output yaml

# This will show the Route, created by the service:
kubectl get route --output yaml

# This will show the Configuration, created by the service:
kubectl get configurations --output yaml

# This will show the Revision, created by the Configuration:
kubectl get revisions --output yaml
```

## Testing the service

Now that you have the service running and the webhook created, send a Pull
Request to the same GitHub repo where you added the webhook. If all is working
right, you'll see the title of the PR will be modified, with the text
`(looks pretty legit)` appended the end of the title.

## Cleaning up

To clean up the sample service:

```shell
kubectl delete --filename service.yaml
```
