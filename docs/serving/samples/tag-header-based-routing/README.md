This sample illustrates the feature "Tag Header Based Routing".

## Tag Header Based Routing Feature

The feature "Tag Header Based Routing" allows users to send requests directly to specific tagged Revisions with
the same URL of Knative Service. In order to achieve this, users only need to set the specific header "Knative-Serving-Tag:
{revision-tag}" into the request.

Currently Istio and Contour Ingress support this feature.

## Prerequestie

1. A Knative cluster that has an Istio Ingress controller or Contour Ingress controller installed
with Knative version 0.16 and above.

1. Move into the docs directory:

```shell
cd $GOPATH/src/github.com/knative/docs
```

## Enabling the feature

This feature is disabled by default. To enable this feature, run the following command:

```
kubectl patch cm config-network -n knative-serving -p '{"data":{"tagHeaderBasedRouting":"Enabled"}}'
```

## Build Images

Follow the instructions in [helloworld-go](../hello-world/helloworld-go) to build the `helloworld` image and upload it
to your container repository.

Replace `{username}` in the [sample.yaml](./sample.yaml) with your Docker Hub username.

## Setting up the revisions with tag

In this sample, two Revisions are created. The first Revision is tagged with "rev1".
With this configuration, users should be able to send requests directly to the first Revision
with the URL of Knative Service plus the header "Knative-Serving-Tag: rev1".

The Knative Service is configured to route 100% traffic to the second Revision, which means if users do not
provide "Knative-Serving-Tag" or provide an incorrect value for "Knative-Serving-Tag", the requests will be
routed to the second Revision.

Run the following command to set up the Knative Service and Revisions.

```
kubectl apply -f docs/serving/samples/tag-header-based-routing/sample.yaml
```

## Check the created resources

Check the two created Revisions using the following command
```
kubectl get revisions
```

You should see there are two Revisions: `tag-header-revision-1` and `tag-header-revision-2`. It may take one or two minutes
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

1.  Run the following command to send request to the first Revision.

    ```
    curl ${INGRESS_IP} -H "Host:tag-header.default.example.com" -H "Knative-Serving-Tag:rev1"
    ```
    where `${INGRESS_IP}` is the IP of your Ingress.

    You should get the following response

    ```
    Hello First Revision!
    ```

1.  Run the following command to send requests without "Knative-Serving-Tag" header

    ```
    curl ${INGRESS_IP} -H "Host:tag-header.default.example.com"
    ```

    You should get the response from the second Revision, which is

    ```
    Hello Second Revision!
    ```

1.  Run the following command to send requests with incorrect "Knative-Serving-Tag" header

    ```
    curl ${INGRESS_IP} -H "Host:tag-header.default.example.com" -H "Knative-Serving-Tag:wrongHeader"
    ```

    You should get the response from the second Revision too, which is

    ```
    Hello Second Revision!
    ```
