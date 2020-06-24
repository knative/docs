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

## Build Images

Follow the instruction in [helloworld-go](../hello-world/helloworld-go) to build the helloworld image and upload it
to your container repository.

Modify [sample.yaml](./sample.yaml) to replace `{username}` with your Docker Hub username.

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

Check created two revisions using the following command
```
kubectl get revisions
```

You should see two revisions: `tag-header-revision-1` and `tag-header-revision-2`. It may take one or two minutes 
for the revisions to become ready.


Check the Knative Service using the following command

```
kubectl get ksvc tag-header -oyaml
```

You should see the following block which indicates the tag `rev1` is successfully added to the first revision.

```
  - revisionName: tag-header-revision-1
    percent: 0
    tag: rev1
  - revisionName: tag-header-revision-2
    percent: 100
```


## Sending request with tag header

1. Run the following command to send request to the first revision.

```
curl ${INGRESS_IP} -H "Host:tag-header.default.example.com" -H "Knative-Serving-Tag:rev1"
```
where ${INGRESS_IP} is the IP of your Ingress.

You should get response

```
Hello First Revision!
```

1. Run the following command to send requests without "Knative-Serving-Tag" header

```
curl ${INGRESS_IP} -H "Host:tag-header.default.example.com"
```

You should get the response from the second revision, which is 

```
Hello Second Revision!
```

1. Run the following command to send requests with incorrect "Knative-Serving-Tag" header

```
curl ${INGRESS_IP} -H "Host:tag-header.default.example.com" -H "Knative-Serving-Tag:wrongHeader"
```

You should get the response from the second revision too, which is

```
Hello Second Revision!
```
