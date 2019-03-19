
This samples builds off the [Creating a RESTful Service](../rest-api-go) sample
to illustrate applying a revision, then using that revision for manual traffic
splitting.

## Prerequisites

1. [Creating a RESTful Service](../rest-api-go).

## Updating the Service

This section describes how to create an revision by deploying a new
configuration.

1. Replace the image reference path with our published image path in the
   configuration files
   (`docs/serving/samples/traffic-splitting/updated_configuration.yaml`:

   - Manually replace:
     `image: github.com/knative/docs/docs/serving/samples/rest-api-go` with
     `image: <YOUR_CONTAINER_REGISTRY>/docs/serving/samples/rest-api-go`

   Or

   - Use run this command:

   ```
   perl -pi -e "s@github.com/knative/docs@${REPO}@g" docs/serving/samples/rest-api-go/updated_configuration.yaml
   ```

2. Deploy the new configuration to update the `RESOURCE` environment variable
   from `stock` to `share`:

```
kubectl apply --filename docs/serving/samples/traffic-splitting/updated_configuration.yaml
```

3. Once deployed, traffic will shift to the new revision automatically. Verify
   the deployment by checking the route status:

```
kubectl get route --output yaml
```

4. When the new route is ready, you can access the new endpoints: The hostname
   and IP address can be found in the same manner as the
   [Creating a RESTful Service](../rest-api-go) sample:

```
export SERVICE_HOST=`kubectl get route stock-route-example --output jsonpath="{.status.domain}"`

# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

export SERVICE_IP=`kubectl get svc $INGRESSGATEWAY --namespace istio-system \
    --output jsonpath="{.status.loadBalancer.ingress[*].ip}"`
```

- Make a request to the index endpoint:

```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}
```

Response body: `Welcome to the share app!`

- Make a request to the `/share` endpoint:

```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/share
```

Response body: `share ticker not found!, require /share/{ticker}`

- Make a request to the `/share` endpoint with a `ticker` parameter:

```
curl --header "Host:$SERVICE_HOST" http://${SERVICE_IP}/share/<ticker>
```

Response body: `share price for ticker <ticker> is <price>`

## Manual Traffic Splitting

This section describes how to manually split traffic to specific revisions.

1. Get your revisions names via:

```
kubectl get revisions
```

```
NAME                                AGE
stock-configuration-example-00001   11m
stock-configuration-example-00002   4m
```

2. Update the `traffic` list in `docs/serving/samples/rest-api-go/sample.yaml` as:

```yaml
traffic:
  - revisionName: <YOUR_FIRST_REVISION_NAME>
    percent: 50
  - revisionName: <YOUR_SECOND_REVISION_NAME>
    percent: 50
```

3. Deploy your traffic revision:

```
kubectl apply --filename docs/serving/samples/rest-api-go/sample.yaml
```

4. Verify the deployment by checking the route status:

```
kubectl get route --output yaml
```

Once updated, you can make `curl` requests to the API using either `stock` or
`share` endpoints.

## Clean Up

To clean up the sample service:

```
kubectl delete --filename docs/serving/samples/traffic-splitting/updated_configuration.yaml
```
