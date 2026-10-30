# Tag Header Based Routing

This sample explains the use of tag header based routing.

## Tag Header Based Routing Feature

Tag header based routing allows users to send requests directly to specific tagged revisions with
the same URL of Knative Service. To do this, you must set the specific header `Knative-Serving-Tag:
{revision-tag}` in the request.

Currently Istio, Contour and Kourier ingress support this feature.

## Prerequisites

1. A Knative cluster that has an ingress controller installed
with Knative v0.16 and later.

1. Move into the root of your clone of the docs repository:

    ```bash
    cd /path/to/docs
    ```

## Enabling tag header based routing

This feature is disabled by default. To enable this feature, run the following command:

```
kubectl patch cm config-features -n knative-serving -p '{"data":{"tag-header-based-routing":"Enabled"}}'
```

## Build images

Follow the instructions in [helloworld-go](../hello-world/helloworld-go/README.md) to build the `helloworld` image and upload it
to your container repository.

Replace `{username}` in [sample.yaml](sample.yaml) with your Docker Hub username.

## Setting up the revisions with tag

In this sample, two Revisions are created. The first Revision is tagged with `rev1`.
With this configuration, users can send requests directly to the first Revision
using the URL of Knative Service plus the header `Knative-Serving-Tag: rev1`.

The Knative Service is configured to route all of the traffic to the second Revision, which means if users do not
provide the `Knative-Serving-Tag` or they provide an incorrect value for `Knative-Serving-Tag`, the requests will be
routed to the second Revision.

The two YAML documents in `sample.yaml` update the same Service. First, apply
only the first document and wait for its Revision to be ready:

```bash
sed '/^---$/q' code-samples/serving/tag-header-based-routing/sample.yaml | kubectl apply -f -
kubectl wait --for=condition=Ready ksvc/tag-header --timeout=180s
```

Then update the Service to create the second Revision and tag the first:

```bash
kubectl apply -f code-samples/serving/tag-header-based-routing/sample.yaml
kubectl wait --for=create revision/tag-header-revision-2 --timeout=180s
kubectl wait --for=condition=Ready revision/tag-header-revision-2 --timeout=180s
kubectl wait --for=condition=Ready ksvc/tag-header --timeout=180s
```

Waiting before applying the complete manifest ensures the first Revision exists
before the second definition replaces the configuration and traffic refers to it.

## Check the created resources

Check the two created Revisions using the following command
```
kubectl get revisions
```

You should see there are two Revisions: `tag-header-revision-1` and `tag-header-revision-2`. It may take a few minutes
for the Revisions to become ready.


Check the Knative Service using the following command

```
kubectl get ksvc tag-header -oyaml
```

You should see the following block which indicates the tag `rev1` is successfully added to the first Revision.

```
  - revisionName: tag-header-revision-1
    percent: 0
    tag: rev1
  - revisionName: tag-header-revision-2
    percent: 100
```


## Sending request with tag header

Set `INGRESS_IP` to the reachable address of your ingress (including a port if
needed). Obtain the Host header from the Service URL instead of assuming a
particular cluster domain:

```bash
SERVICE_URL=$(kubectl get ksvc tag-header -o jsonpath='{.status.url}')
SERVICE_HOST=${SERVICE_URL#*://}
```

The following examples use an HTTP ingress endpoint.

1.  Run the following command to send a request to the first Revision.

    ```
    curl "http://${INGRESS_IP}" -H "Host:${SERVICE_HOST}" -H "Knative-Serving-Tag:rev1"
    ```
    where `${INGRESS_IP}` is the address of your ingress.

    You should get the following response:

    ```
    Hello First Revision!
    ```

1.  Run the following command to send requests without the `Knative-Serving-Tag` header:

    ```
    curl "http://${INGRESS_IP}" -H "Host:${SERVICE_HOST}"
    ```

    You should get the response from the second Revision:

    ```
    Hello Second Revision!
    ```

1.  Run the following command to send requests with an incorrect `Knative-Serving-Tag` header:

    ```
    curl "http://${INGRESS_IP}" -H "Host:${SERVICE_HOST}" -H "Knative-Serving-Tag:wrongHeader"
    ```

    You should get the response from the second Revision:

    ```
    Hello Second Revision!
    ```

## Cleanup

Delete the Service and its Revisions when finished:

```bash
kubectl delete ksvc tag-header
```
