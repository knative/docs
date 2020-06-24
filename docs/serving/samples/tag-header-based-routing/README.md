This sample illustrates the feature "Tag Header Based Routing".

## The feature of Tag Header Based Routing

The feature of Tag Header Based Routing allows users to send requests directly to specific revisions with
the same URL of Knative Service with specific request header "Knative-Serving-Tag: {revision-tag}".

Currently Istio and Contour Ingress support this feature.

## Prerequestie

1. A Knative cluster having Istio Ingress controller or Contour Ingress controller installed
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

## Setting up the revisions with tag

In this sample, two revisions are created. The first revision is tagged with "rev1".
With this configuration, users should be able to send requests directly to the first revision 
with the URL of Knative Service plus the header "Knative-Serving-Tag: rev1".

The Knative Service are configured to route 100% traffic to the second revision, which means if users do not
provide "Knative-Serving-Tag" or provide an incorrect value for "Knative-Serving-Tag", the requests will be
routed to the second revision.

Run the following command to set up above configurations.

```
kubectl apply -f docs/serving/samples/tag-header-based-routing/sample.yaml
```

## Check the created resources

Check two revisions become ready using the following command. It may take one or two minutes for the revisions
to become ready.

```
kubectl get revisions
```

Check the Knative Service becomes ready and is configured correctly

```
kubectl get ksvc tag-header -oyaml
```

You should see the following block which indicates the tag is successfully added to the first revision.


## Sending request with tag header

1. Run the following command to send request to the first revision.

```
```

You should get response
```
```

1. Run the following command to send requests without "Knative-Serving-Tag" header

```
```

You should get the response from the second revision, which is 
```
```

1. Run the following command to send requests with incorrect "Knative-Serving-Tag" header

```
```

You should get the response from the second revision too, which is 
```
```

