# Debugging Issues with Your Application

You deployed your app to Knative Serving, but it isn't working as expected.
Go through this step-by-step guide to understand what failed.

## Check command-line output

Check your deploy command output to see whether it succeeded or not. If your
deployment process was terminated, you should see an error message
in the output that describes the reason why the deployment failed.

This kind of failure is most likely due to either a misconfigured manifest or
wrong command. For example, the following output says that you must configure
route traffic percent to sum to 100:

```
Error from server (InternalError): error when applying patch:
{"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"serving.knative.dev/v1alpha1\",\"kind\":\"Route\",\"metadata\":{\"annotations\":{},\"name\":\"route-example\",\"namespace\":\"default\"},\"spec\":{\"traffic\":[{\"configurationName\":\"configuration-example\",\"percent\":50}]}}\n"}},"spec":{"traffic":[{"configurationName":"configuration-example","percent":50}]}}
to:
&{0xc421d98240 0xc421e77490 default route-example STDIN 0xc421db0488 264682 false}
for: "STDIN": Internal error occurred: admission webhook "webhook.knative.dev" denied the request: mutation failed: The route must have traffic percent sum equal to 100.
ERROR: Non-zero return code '1' from command: Process exited with status 1
```

## Check application logs

Knative Serving provides default out-of-the-box logs for your application.
Access your application logs using [Accessing Logs](./accessing-logs.md) page.

## Check Route status

Run the following command to get the `status` of the `Route` object with which
you deployed your application:

```shell
kubectl get route <route-name> --output yaml
```

The `conditions` in `status` provide the reason if there is any failure. For
details, see Knative
[Error Conditions and Reporting](https://github.com/knative/serving/blob/master/docs/spec/errors.md)(currently some of them
are not implemented yet).

## Check Revision status

If you configure your `Route` with `Configuration`, run the following
command to get the name of the `Revision` created for you deployment
(look up the configuration name in the `Route` .yaml file):

```shell
kubectl get configuration <configuration-name> --output jsonpath="{.status.latestCreatedRevisionName}"
```

If you configure your `Route` with `Revision` directly, look up the revision
name in the `Route` yaml file.

Then run the following command:

```shell
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
- [Check application logs](#check-application-logs)

If you see other conditions, to debug further:

- Look up the meaning of the conditions in Knative
  [Error Conditions and Reporting](https://github.com/knative/serving/blob/master/docs/spec/errors.md). Note: some of them
  are not implemented yet. An alternative is to
  [check Pod status](#check-pod-status).
- If you are using `BUILD` to deploy and the `BuildComplete` condition is not
  `True`, [check BUILD status](#check-build-status).

## Check Pod status

To get the `Pod`s for all your deployments:

```shell
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

```shell
kubectl get pod <pod-name> --output yaml

```

If you see issues with "user-container" container in the containerStatuses, check your application logs as described below.

## Check Build status

If you are using Build to deploy, run the following command to get the Build for
your `Revision`:

```shell
kubectl get build $(kubectl get revision <revision-name> --output jsonpath="{.spec.buildName}") --output yaml
```

If there is any failure, the `conditions` in `status` provide the reason. To
access build logs, first execute `kubectl proxy` and then open [Kibana UI](http://localhost:8001/api/v1/namespaces/knative-monitoring/services/kibana-logging/proxy/app/kibana).
Use any of the following filters within Kibana UI to
see build logs. _(See [telemetry guide](../telemetry.md) for more information on
logging and monitoring features of Knative Serving.)_

- All build logs: `_exists_:"kubernetes.labels.build-name"`
- Build logs for a specific build: `kubernetes.labels.build-name:"<BUILD NAME>"`
- Build logs for a specific build and step: `kubernetes.labels.build-name:"<BUILD NAME>" AND kubernetes.container_name:"build-step-<BUILD STEP NAME>"`

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
