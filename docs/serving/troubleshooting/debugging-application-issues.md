# Debugging application issues

If you have deployed an application but are having issues, you can use the following steps to troubleshoot the application.

## Check terminal output

Check your deploy command output to see whether it succeeded or not. If your
deployment process was terminated, you should see an error message in the output
that describes the reason why the deployment failed.

This kind of failure is most likely due to either a misconfigured manifest or
wrong command. For example, the following output says that you must configure
route traffic percent to sum to 100:

```
Error from server (InternalError): error when applying patch:
{"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"serving.knative.dev/v1\",\"kind\":\"Route\",\"metadata\":{\"annotations\":{},\"name\":\"route-example\",\"namespace\":\"default\"},\"spec\":{\"traffic\":[{\"configurationName\":\"configuration-example\",\"percent\":50}]}}\n"}},"spec":{"traffic":[{"configurationName":"configuration-example","percent":50}]}}
to:
&{0xc421d98240 0xc421e77490 default route-example STDIN 0xc421db0488 264682 false}
for: "STDIN": Internal error occurred: admission webhook "webhook.knative.dev" denied the request: mutation failed: The route must have traffic percent sum equal to 100.
ERROR: Non-zero return code '1' from command: Process exited with status 1
```

## Check Route status

Run the following command to get the `status` of the `Route` object with which
you deployed your application:

```bash
kubectl get route <route-name> --output yaml
```

The `conditions` in `status` provide the reason if there is any failure. For
details, see Knative
[Error Conditions and Reporting](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#error-signalling).

### Check Ingress/Istio routing

To list all Ingress resources and their corresponding labels, run the following command:

```bash
kubectl get ingresses.networking.internal.knative.dev -o=custom-columns='NAME:.metadata.name,LABELS:.metadata.labels'
NAME            LABELS
helloworld-go   map[serving.knative.dev/route:helloworld-go serving.knative.dev/routeNamespace:default serving.knative.dev/service:helloworld-go]
```

The labels `serving.knative.dev/route` and `serving.knative.dev/routeNamespace`
indicate the Route in which the Ingress resource resides. Your Route and
Ingress should be listed. If your Ingress does not exist, the route
controller believes that the Revisions targeted by your Route/Service isn't
ready. Please proceed to later sections to diagnose Revision readiness status.

Otherwise, run the following command to look at the ClusterIngress created for
your Route

```
kubectl get ingresses.networking.internal.knative.dev <INGRESS_NAME> --output yaml
```

particularly, look at the `status:` section. If the Ingress is working
correctly, we should see the condition with `type=Ready` to have `status=True`.
Otherwise, there will be error messages.

Now, if Ingress shows status `Ready`, there must be a corresponding
VirtualService. Run the following command:

```bash
kubectl get virtualservice -l networking.internal.knative.dev/ingress=<INGRESS_NAME> -n <INGRESS_NAMESPACE> --output yaml
```

the network configuration in VirtualService must match that of Ingress
and Route. VirtualService currently doesn't expose a Status field, so if one
exists and have matching configurations with Ingress and Route, you may
want to wait a little bit for those settings to propagate.

If you are familiar with Istio and `istioctl`, you may try using `istioctl` to
look deeper using Istio
[guide](https://istio.io/help/ops/traffic-management/proxy-cmd/).

### Check Ingress status

Knative uses a LoadBalancer service called `istio-ingressgateway` Service.

To check the IP address of your Ingress, use

```bash
kubectl get svc -n istio-system istio-ingressgateway
```

If there is no external IP address, use

```bash
kubectl describe svc istio-ingressgateway -n istio-system
```

to see a reason why IP addresses weren't provisioned. Most likely it is due to a
quota issue.

## Check Revision status

If you configure your `Route` with `Configuration`, run the following command to
get the name of the `Revision` created for you deployment (look up the
configuration name in the `Route` .yaml file):

```bash
kubectl get configuration <configuration-name> --output jsonpath="{.status.latestCreatedRevisionName}"
```

If you configure your `Route` with `Revision` directly, look up the revision
name in the `Route` yaml file.

Then run the following command:

```bash
kubectl get revision <revision-name> --output yaml
```

A ready `Revision` should have the following condition in `status`:

```yaml
conditions:
  - reason: ServiceReady
    status: "True"
    type: Ready
```

If you see this condition, check the following to continue debugging:

- [Check Pod status](#check-pod-status)
- [Check Istio routing](#check-ingressistio-routing)

!!! tip
    If you see other conditions, you can look up the meaning of the conditions in Knative [Error Conditions and Reporting](https://github.com/knative/serving/blob/main/docs/spec/errors.md). An alternative is to [check Pod status](#check-pod-status).

## Check Pod status

To get the `Pod`s for all your deployments:

```bash
kubectl get pods
```

This command should list all `Pod`s with brief status. For example:

```text
NAME                                                      READY     STATUS             RESTARTS   AGE
configuration-example-00001-deployment-659747ff99-9bvr4   2/2       Running            0          3h
configuration-example-00002-deployment-5f475b7849-gxcht   1/2       CrashLoopBackOff   2          36s
```

Choose one and use the following command to see detailed information for its
`status`. Some useful fields are `conditions` and `containerStatuses`:

```bash
kubectl get pod <pod-name> --output yaml

```
