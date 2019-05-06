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

## Updating to Release Mode

The service was originally created with a mode of `runLatest`. In `runLatest`
mode, the service serves the latest Revision that is ready to handle incoming
traffic. To split traffic between multiple Revisions, the Service mode will need
to be changed to `release` mode. The `release` mode differs from `runLatest` in
that it requires a `revisions` list. The `revisions` list accepts 1 or 2
Revisions that will be served by the base domain of the service. When 2
Revisions are present in the list a `rolloutPercent` parameter specifies the
percentage of traffic to send to each Revision.

This first step will update the Service to release mode with a single Revision.

1. To populate the `revisions` list the name of the created Revision is
   required. The command below captures the names of all created Revisions as an
   array so it can be substituted it into the YAML.

```shell
REVISIONS=($(kubectl get revision -l "serving.knative.dev/service=stock-service-example" -o \
jsonpath="{.items[*].metadata.name}"))
echo ${REVISIONS[*]}
```

2. The `release_sample.yaml` is setup in this directory to allow enable
   substituting the Revision name into the file with the `envsubst` utility.
   Executing the command below will update the Service to release mode with the
   queried Revision name.

- Note: The command below expects `$REPO` to still be exported. See
  [RESTful Service Setup](https://github.com/knative/docs/tree/master/serving/samples/rest-api-go#setup)
  to set it.

```shell
CURRENT=${REVISIONS[0]} \
envsubst < serving/samples/traffic-splitting/release_sample.yaml \
| kubectl replace --filename -
```

3. The `spec` of the Service should now show `release` with the Revision name
   retrieved above.

```shell
kubectl get ksvc stock-service-example --output yaml
```

## Updating the Service

This section describes how to create a new Revision by updating your Service.

A new Revision is created every time a value in the `revisionTemplate` section
of the Service `spec` is updated. The `updated_sample.yaml` in this folder
changes the environment variable `RESOURCE` from `stock` to `share`. Applying
this change will result in a new Revision.

For comparison, you can diff the `release_sample.yaml` with the
`updated_sample.yaml`.

```shell
diff serving/samples/traffic-splitting/release_sample.yaml \
serving/samples/traffic-splitting/updated_sample.yaml
```

1.  Execute the command below to update the environment variable in the Service
    resulting in a new Revision.

```shell
CURRENT=${REVISIONS[0]} \
envsubst < serving/samples/traffic-splitting/updated_sample.yaml \
| kubectl apply --filename -
```

2. Since we are using a `release` service, traffic will _not_ shift to the new
   Revision automatically. However, it will be available from the subdomain
   `latest`. This can be verified through the Service status:

```shell
kubectl get ksvc stock-service-example --output yaml
```

3. The readiness of the Service can be verified through the Service Conditions.
   When the Service conditions report it is ready again, you can access the new
   Revision using the same method as found in the
   [previous sample](../rest-api-go/README.md#access-the-service) by prefixing
   the Service hostname with `latest.`.

```shell
curl --header "Host:latest.${SERVICE_HOSTNAME}" http://${INGRESS_IP}
```

- Hitting the top domain (or `current.`) will hit the Revision at the first
  index of the `revisions` list:

```shell
curl --header "Host:${SERVICE_HOSTNAME}" http://${INGRESS_IP}
curl --header "Host:current.${SERVICE_HOSTNAME}" http://${INGRESS_IP}
```

## Traffic Splitting

Updating the service to split traffic between the two revisions is done by
placing a second revision in of the `revisions` list and specifying a
`rolloutPercent`. The `rolloutPercent` is the percentage of traffic to send to
the second element in the list. When the Service is Ready the traffic will be
split as desired for the base domain, and a subdomain of `candidate` will be
available pointing to the second Revision.

1. Get the latest list of revisions by executing the command below:

```shell
REVISIONS=($(kubectl get revision -l "serving.knative.dev/service=stock-service-example" --output \
jsonpath="{.items[*].metadata.name}"))
echo ${REVISIONS[*]}
```

2. Update the `revisions` list in
   `serving/samples/traffic-splitting/split_sample.yaml`. A `rolloutPercent` of
   50 has already been specified, but can be changed if desired by editing the
   `split_sample.yaml` file.

```shell
CURRENT=${REVISIONS[0]} CANDIDATE=${REVISIONS[1]} \
envsubst < serving/samples/traffic-splitting/split_sample.yaml \
| kubectl apply --filename -
```

3. Verify the deployment by checking the service status:

```shell
kubectl get ksvc --output yaml
```

4. Once updated, `curl` requests to the base domain should result in responses
   split evenly between `Welcome to the share app!` and
   `Welcome to the stock app!`.

```shell
curl --header "Host:${SERVICE_HOSTNAME}" http://${INGRESS_IP}
```

5. Much like the `current` and `latest` subdomains there should now be a
   `candidate` subdomain that should return `Welcome to the share app!` as it
   hits the second index of the `revisions` list.

```shell
curl --header "Host:candidate.${SERVICE_HOSTNAME}" http://${INGRESS_IP}
```

## Clean Up

To clean up the sample service:

```shell
kubectl delete --filename serving/samples/traffic-splitting/split_sample.yaml
```
