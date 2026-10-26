# GitHub webhook sample - Go

A handler written in Go that demonstrates interacting with GitHub through a
webhook.

## Before you begin

You must meet the following requirements to run this sample:

- Own a public domain. For example, you can create a domain with
  [Google Domains](https://domains.google/).
- A Kubernetes cluster running with the following:
  - Knative Serving must be installed. See
    [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
  - Your Knative cluster must be
    [configured to use your custom domain](https://knative.dev/docs/serving/using-a-custom-domain).
  - You must ensure that your Knative cluster uses a static IP address refer to your provider's documentation.
- An installed version of [Docker](https://www.docker.com).
- A [Docker Hub account](https://hub.docker.com/) to which you are able to
  upload your sample's container image.

## Build the sample code

1. Download a copy of the code:

   ```bash
   git clone https://github.com/knative/docs.git knative-docs
   cd knative-docs/code-samples/serving/gitwebhook-go
   ```

1. Use Docker to build a container image for this service. Replace
   `{DOCKER_HUB_USERNAME}` with your Docker Hub username in the following
   commands.

   ```bash
   export DOCKER_HUB_USERNAME=username

   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "${DOCKER_HUB_USERNAME}/gitwebhook-go" --push .
   ```

1. Create a secret that holds two values from GitHub:

   - A
     [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
     that you will use to make API requests to GitHub.
     For a fine-grained token, select the target repository and grant
     **Pull requests: Read and write** permission.
   - A webhook secret that you will use to validate requests.

   1. Base64 encode the access token:

      ```bash
      $ echo -n "45d382d4a9a93c453fb7c8adc109121e7c29fa3ca" | base64
      NDVkMzgyZDRhOWE5M2M0NTNmYjdjOGFkYzEwOTEyMWU3YzI5ZmEzY2E=
      ```

   1. Copy the encoded access token into `github-secret.yaml` next to
      `personalAccessToken:`.

   1. Create a webhook secret value unique to this sample, base64 encode it, and
      copy it into `github-secret.yaml` next to `webhookSecret:`:

      ```bash
      $ echo -n "mygithubwebhooksecret" | base64
      bXlnaXRodWJ3ZWJob29rc2VjcmV0
      ```

   1. Apply the secret to your cluster:

      ```bash
      kubectl apply --filename github-secret.yaml
      ```

1. Next, update the image in the checked-in [Service manifest](service.yaml)
   to reference the tag you built. The manifest reads `GITHUB_PERSONAL_TOKEN` and
   `WEBHOOK_SECRET` from the keys in [the Secret manifest](github-secret.yaml);
   keep those references when changing the image.

1. Use `kubectl` to apply the `service.yaml` file.

   ```bash
   $ kubectl apply --filename service.yaml
   ```

   Response:

   ```bash
   service "gitwebhook" created
   ```

1. Create a webhook in your GitHub repo using the URL for your `gitwebhook`
   service:

   1. Retrieve the URL for this service, using the following command:

      ```bash
      $ kubectl get ksvc gitwebhook \
         --output=custom-columns=NAME:.metadata.name,URL:.status.url
      ```

      Example response:

      ```bash
      NAME                URL
      gitwebhook          http://gitwebhook.default.MYCUSTOMDOMAIN.com
      ```

      where `MYCUSTOMDOMAIN` is the domain that you set as your
      [custom domain](https://knative.dev/docs/serving/using-a-custom-domain).

   1. Go to the GitHub repository for which you have privileges to create a
      webhook.

   1. Click **Settings** > **Webhooks** > **Add webhook** to open the Webhooks
      page.

   1. Enter the URL from the `kubectl get ksvc gitwebhook` command as the
      **Payload URL**, including its scheme. For example:
      `https://gitwebhook.default.MYCUSTOMDOMAIN.com/`.
      Use HTTPS with a valid certificate for a publicly accessible webhook.

   1. Set the **Content type** to `application/json`.

   1. Enter your webhook secret in **Secret** using the original base value that
      you set in `webhookSecret` (not the base64 encoded value). For example:
      `mygithubwebhooksecret`

   1. Select **Let me select individual events**, then select **Pull requests**.
      The default **Just the push event** does not invoke this sample's handler.

   1. When using HTTPS, keep **SSL Validation** enabled. See
      [enabling TLS certificates](https://knative.dev/docs/serving/using-a-tls-cert).

   1. Click **Add webhook** to create the webhook.

## Exploring

Once deployed, you can inspect the created resources with `kubectl` commands:

```bash
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

The server listens on `PORT` (default `8080`). `WEBHOOK_SECRET` validates the
incoming GitHub `X-Hub-Signature` HMAC-SHA1 header; if it is unset or empty,
signature verification is disabled. Always configure it for a public endpoint.
`GITHUB_PERSONAL_TOKEN` authenticates outbound GitHub API requests.
`GITHUB_API_URL` optionally sets an absolute HTTP(S) API base URL (for example,
`https://github.example.com/api/v3/` for GitHub Enterprise); when unset, the
standard GitHub API is used. Configure this only for a trusted endpoint, since
API requests include the token. The webhook
endpoint is `/` and accepts only POST requests. Only pull request events trigger
an update; other events, including GitHub's initial ping, are ignored.

Now that you have the service running and the webhook created, send a Pull
Request to the same GitHub repo where you added the webhook. If all is working
right, you'll see the title of the PR will be modified, with the text
`(looks pretty legit)` appended the end of the title.

## Cleaning up

To clean up the sample service:

```bash
kubectl delete --filename service.yaml
kubectl delete --filename github-secret.yaml
```
