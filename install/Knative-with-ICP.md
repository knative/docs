# Knative Install on ICP

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires a ICP(IBM Cloud Private) cluster v2.1.0.3 or newer. 

## Installing Istio

Knative depends on Istio. Run the following to install Istio. (We are changing
`LoadBalancer` to `NodePort` for the `istio-ingress` service).

```shell
curl -L https://raw.githubusercontent.com/knative/serving/v0.2.1/third_party/istio-1.0.2/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Monitor the Istio components until all of the components show a `STATUS` of
`Running` or `Completed`:

```shell
kubectl get pods --namespace istio-system
```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
  command to view the component's status updates in real time. Use CTRL+C to exit watch mode.

## Installing Knative Serving

Next, install [Knative Serving](https://github.com/knative/serving):

Because you have limited resources available, use the
`https://github.com/knative/serving/releases/download/v0.2.1/release-lite.yaml`
file, which omits some of the monitoring components to reduce the memory used by
the Knative components. To use the provided `release-lite.yaml` release, run:

```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.1/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

Put the namespaces ``knative-serving``, ``knative-build``, ``knative-monitoring`` and ``knative-eventing`` into pod security policy ``ibm-privileged-psp`` as follows.

The ICP Pod 
```shell
# kubectl get psp
NAME                        PRIV      CAPS                                                                                                                  SELINUX    RUNASUSER          FSGROUP     SUPGROUP    READONLYROOTFS   VOLUMES
ibm-anyuid-hostaccess-psp   false     SETPCAP,AUDIT_WRITE,CHOWN,NET_RAW,DAC_OVERRIDE,FOWNER,FSETID,KILL,SETUID,SETGID,NET_BIND_SERVICE,SYS_CHROOT,SETFCAP   RunAsAny   RunAsAny           RunAsAny    RunAsAny    false            *
ibm-anyuid-hostpath-psp     false     SETPCAP,AUDIT_WRITE,CHOWN,NET_RAW,DAC_OVERRIDE,FOWNER,FSETID,KILL,SETUID,SETGID,NET_BIND_SERVICE,SYS_CHROOT,SETFCAP   RunAsAny   RunAsAny           RunAsAny    RunAsAny    false            *
ibm-anyuid-psp              false     SETPCAP,AUDIT_WRITE,CHOWN,NET_RAW,DAC_OVERRIDE,FOWNER,FSETID,KILL,SETUID,SETGID,NET_BIND_SERVICE,SYS_CHROOT,SETFCAP   RunAsAny   RunAsAny           RunAsAny    RunAsAny    false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
ibm-privileged-psp          true      *                                                                                                                     RunAsAny   RunAsAny           RunAsAny    RunAsAny    false            *
ibm-restricted-psp          false                                                                                                                           RunAsAny   MustRunAsNonRoot   MustRunAs   MustRunAs   false            configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
```

Create a cluster role for the pod security policy resource. The resourceNames for this role must be the name of the pod security policy that was created previous. Here we use ``ibm-privileged-psp``.
Create a YAML file for the cluster role.
```shell
vim knative-clusterrole.yaml
```
```shell
 apiVersion: rbac.authorization.k8s.io/v1
 kind: ClusterRole
 metadata:
  name: knative-role
 rules:
  -
    apiGroups:
      - extensions
    resourceNames:
      - ibm-privileged-psp
    resources:
      - podsecuritypolicies
    verbs:
      - use
```
Create the role.
```shell
kubectl create -f knative-clusterrole.yaml
```
The output resembles the following code:
```shell
clusterrole "knative-role" created
```

Set up cluster role binding for the service account in knative namespace. By using this role binding, you can set the service accounts in the namespace to use the pod security policy that you created.
```shell
vim knative-clusterrolebinding.yaml
```
```shell
 apiVersion: rbac.authorization.k8s.io/v1
 kind: ClusterRoleBinding
 metadata:
  name: knative-serving-psp-users
 roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: knative-role
 subjects:
  -
    apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: "system:serviceaccounts:knative-serving"
```
```shell
 kubectl create -f knative-clusterrolebinding.yaml
```
You can use the same mothed add the other knative namespaces to ``ibm-privileged-psp`` pod security policy.

Monitor the Knative components until all of the components show a `STATUS` of
`Running`:

```shell
kubectl get pods --namespace knative-serving
```

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
  command to view the component's status updates in real time. Use CTRL+C to exit watch mode.

Now you can deploy an app to your newly created Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> Note: When looking up the IP address to use for accessing your app, you need to look up
  the NodePort for the `knative-ingressgateway` as well as the IP address used for ICP.
  You can use the following command to look up the value to use for the {IP_ADDRESS} placeholder
  used in the samples:
  ```shell
  echo $(ICP cluster ip):$(kubectl get svc knative-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
  ```

## Cleaning up

Delete the Kubernetes cluster along with Knative, Istio, and any deployed apps:

```shell
kubectl delete
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
