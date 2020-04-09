This samples builds off of the [Creating a RESTful Service](../rest-api-go)
sample to illustrate updating a Service to create a new Revision as well as
splitting traffic between the two created Revisions.

## Prerequisites

1. Complete the Service creation steps in
   [Creating a RESTful Service](../rest-api-go).
1. Move into the docs directory:

```shell
cd $GOPATH/src/github.com/knative/docs
```

## Using the `traffic:` block

The service was originally created without a `traffic:` block, which means that
it will automatically deploy the latest updates as they become ready. To split
traffic between multiple Revisions, we will start to use a customized `traffic:`
block. The `traffic:` block enables users to split traffic over any number of
fixed Revisions, or the floating "latest revision" for the Service. It also
enables users to name the specific sub-routes, so that they can be directly
addressed for qualification or debugging.

The first thing we will do is look at the traffic block that was defaulted for
us in the previous sample:

1. Fetch the state of the Service, and note the `traffic:` block that will run
   the latest ready revision, each time we update our template. Also note that
   under `status:` we see a specific `revisionName:` here, which is what it has
   resolved to (in this case the name we asked for).

```shell
$ kubectl get ksvc -oyaml stock-service-example
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: stock-service-example
  ...
spec:
  template: ... # A defaulted version of what we provided.

  traffic:
  - latestRevision: true
    percent: 100

status:
  ...
  traffic:
  - percent: 100
    revisionName: stock-service-example-first
```

1. The `release_sample.yaml` in this directory overwrites the defaulted traffic
   block with a block that fixes traffic to the revision
   `stock-service-example-first`, while keeping the latest ready revision
   available via the sub-route "latest".

```shell
kubectl apply --filename docs/serving/samples/traffic-splitting/release_sample.yaml
```

1. The `spec` of the Service should now show our `traffic` block with the
   Revision name we specified above.

```shell
kubectl get ksvc stock-service-example --output yaml
```

## Updating the Service

This section describes how to create a new Revision by updating your Service.

A new Revision is created every time a value in the `template` section of the
Service `spec` is updated. The `updated_sample.yaml` in this folder changes the
environment variable `RESOURCE` from `stock` to `share`. Applying this change
will result in a new Revision.

For comparison, you can diff the `release_sample.yaml` with the
`updated_sample.yaml`.

```shell
diff serving/samples/traffic-splitting/release_sample.yaml \
serving/samples/traffic-splitting/updated_sample.yaml
```

1.  Execute the command below to update Service, resulting in a new Revision.

```shell
kubectl apply --filename docs/serving/samples/traffic-splitting/updated_sample.yaml
```

2. With our `traffic` block, traffic will _not_ shift to the new Revision
   automatically. However, it will be available via the URL associated with our
   `latest` sub-route. This can be verified through the Service status, by
   finding the entry of `status.traffic` for `latest`:

```shell
kubectl get ksvc stock-service-example --output yaml
```

3. The readiness of the Service can be verified through the Service Conditions.
   When the Service conditions report it is ready again, you can access the new
   Revision using the same method as found in the
   [previous sample](../rest-api-go/README.md#access-the-service) using the
   Service hostname found above.

```shell
# Replace "latest" with whichever tag for which we want the hostname.
export LATEST_HOSTNAME=`kubectl get ksvc stock-service-example --output jsonpath="{.status.traffic[?(@.tag=='latest')].url}" | cut -d'/' -f 3`
curl --header "Host: ${LATEST_HOSTNAME}" http://${INGRESS_IP}
```

- Visiting the Service's domain will still hit the original Revision, since we
  configured it to receive 100% of our main traffic (you can also use the
  `current` sub-route).

```shell
curl --header "Host:${SERVICE_HOSTNAME}" http://${INGRESS_IP}
```

## Traffic Splitting

Updating the service to split traffic between the two revisions is done by
extending our `traffic` list, and splitting the `percent` across them.

1.  Execute the command below to update Service, resulting in a 50/50 traffic
    split.

```shell
kubectl apply --filename docs/serving/samples/traffic-splitting/split_sample.yaml
```

2. Verify the deployment by checking the service status:

```shell
kubectl get ksvc --output yaml
```

3. Once updated, `curl` requests to the base domain should result in responses
   split evenly between `Welcome to the share app!` and
   `Welcome to the stock app!`.

```shell
curl --header "Host:${SERVICE_HOSTNAME}" http://${INGRESS_IP}
```

## Clean Up

To clean up the sample service:

```shell
kubectl delete --filename docs/serving/samples/traffic-splitting/split_sample.yaml
```
