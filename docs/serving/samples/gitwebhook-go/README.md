A handler written in Go that demonstrates interacting with GitHub through a
webhook.

## Before you begin

You must meet the following requirements to run this sample:

- Own a public domain. For example, you can create a domain with
  [Google Domains](https://domains.google/).
- A Kubernetes cluster running with the following:
  - Knative Serving must be installed. For details about setting up a Knative
    cluster, see the [installation guides](../../../install/README.md).
  - Your Knative cluster must be
    [configured to use your custom domain](../../using-a-custom-domain.md).
  - You must ensure that your Knative cluster uses a static IP address:
    - For Google Kubernetes Engine, see
      [assigning a static IP address](../../gke-assigning-static-ip-address.md).
    - For other cloud providers, refer to your provider's documentation.
- An installed version of [Docker](https://www.docker.com).
- A [Docker Hub account](https://hub.docker.com/) to which you are able to
  upload your sample's container image.

## Build the sample code

1. Download a copy of the code:

   ```shell
   git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
   cd knative-docs/docs/serving/samples/gitwebhook-go
   ```

1. Use Docker to build a container image for this service. Replace
   `{DOCKER_HUB_USERNAME}` with your Docker Hub username in the following
   commands.

   ```shell
   export DOCKER_HUB_USERNAME=username

   # Build the container, run from the project folder
   docker build -t ${DOCKER_HUB_USERNAME}/gitwebhook-go .

   # Push the container to the registry
   docker push ${DOCKER_HUB_USERNAME}/gitwebhook-go
   ```

1. Create a secret that holds two values from GitHub:

   - A
     [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
     that you will use to make API requests to GitHub.
   - Ensure that you grant `read/write` permission in the repo for that personal
     access token.

   1. Follow the GitHub instructions to

   - A webhook secret that you will use to validate requests.

   1. Base64 encode the access token:

      ```shell
      $ echo -n "45d382d4a9a93c453fb7c8adc109121e7c29fa3ca" | base64
      NDVkMzgyZDRhOWE5M2M0NTNmYjdjOGFkYzEwOTEyMWU3YzI5ZmEzY2E=
      ```

   1. Copy the encoded access token into `github-secret.yaml` next to
      `personalAccessToken:`.

   1. Create a webhook secret value unique to this sample, base64 encode it, and
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
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: gitwebhook
     namespace: default
   spec:
     template:
       spec:
         containers:
           - # Replace {DOCKER_HUB_USERNAME} with your actual docker hub username
             image: docker.io/{DOCKER_HUB_USERNAME}/gitwebhook-go:latest
             env:
               - name: GITHUB_PERSONAL_TOKEN
                 valueFrom:
                   secretKeyRef:
                     name: githubsecret
                     key: personalAccessToken
               - name: WEBHOOK_SECRET
                 valueFrom:
                   secretKeyRef:
                     name: githubsecret
                     key: webhookSecret
   ```

1. Use `kubectl` to apply the `service.yaml` file.

   ```shell
   $ kubectl apply --filename service.yaml
   ```

   Response:

   ```shell
   service "gitwebhook" created
   ```

1. Create a webhook in your GitHub repo using the URL for your `gitwebhook`
   service:

   1. Retrieve the hostname for this service, using the following command:

      ```shell
      $ kubectl get ksvc gitwebhook \
         --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
      ```

      Example response:

      ```shell
      NAME                DOMAIN
      gitwebhook          gitwebhook.default.MYCUSTOMDOMAIN.com
      ```

      where `MYCUSTOMDOMAIN` is the domain that you set as your
      [custom domain](../../using-a-custom-domain.md).

   1. Go to the GitHub repository for which you have privileges to create a
      webhook.

   1. Click **Settings** > **Webhooks** > **Add webhook** to open the Webhooks
      page.

   1. Enter the **Payload URL** as `http://{DOMAIN}`, where `{DOMAIN}` is the
      address from the `kubectl get ksvc gitwebhook` command. For example:
      `http://gitwebhook.default.MYCUSTOMDOMAIN.com`

   1. Set the **Content type** to `application/json`.

   1. Enter your webhook secret in **Secret** using the original base value that
      you set in `webhookSecret` (not the base64 encoded value). For example:
      `mygithubwebhooksecret`

   1. If you did not [enabled TLS certificates](../../using-a-tls-cert.md),
      click **Disable** under **SSL Validation**.

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
