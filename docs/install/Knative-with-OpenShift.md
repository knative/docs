---
title: "Install on OpenShift"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 15
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) on an
[OpenShift](https://github.com/openshift/origin) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](../).

## Before you begin

These instructions will run an OpenShift 3.10 (Kubernetes 1.11) cluster on your
local machine using
[`oc cluster up`](https://docs.openshift.org/latest/getting_started/administrators.html#running-in-a-docker-container)
to test-drive knative.

## Install `oc` (openshift cli)

You can install the latest version of `oc`, the OpenShift CLI, into your local
directory by downloading the right release tarball for your OS from the
[releases page](https://github.com/openshift/origin/releases/tag/v3.10.0).

```shell
export OS=<your OS here>
curl https://github.com/openshift/origin/releases/download/v3.10.0/openshift-origin-client-tools-v3.10.0-dd10d17-$OS-64bit.tar.gz -o oc.tar.gz
tar zvf oc.tar.gz -x openshift-origin-client-tools-v3.10.0-dd10d17-$OS-64bit/oc --strip=1

# You will now have the oc binary in your local directory
```

## Scripted cluster setup and installation

For Linux and Mac, you can optionally run a
[script](scripts/knative-with-openshift.sh) that automates the steps on this
page.

Once you have `oc` present on your machine and in your `PATH`, you can simply
run [this script](scripts/knative-with-openshift.sh); it will:

- Create a new OpenShift cluster on your local machine with `oc cluster up`
- Install Istio and Knative serving
- Log you in as the cluster administrator
- Set up the default namespace for istio autoinjection

Once the script completes, you'll be ready to test out Knative!

## Creating a new OpenShift cluster

Create a new OpenShift cluster on your local machine using `oc cluster up`:

```shell
oc cluster up --write-config

# Enable admission webhooks
sed -i -e 's/"admissionConfig":{"pluginConfig":null}/"admissionConfig": {\
    "pluginConfig": {\
        "ValidatingAdmissionWebhook": {\
            "configuration": {\
                "apiVersion": "v1",\
                "kind": "DefaultAdmissionConfig",\
                "disable": false\
            }\
        },\
        "MutatingAdmissionWebhook": {\
            "configuration": {\
                "apiVersion": "v1",\
                "kind": "DefaultAdmissionConfig",\
                "disable": false\
            }\
        }\
    }\
}/' openshift.local.clusterup/kube-apiserver/master-config.yaml

oc cluster up --server-loglevel=5
```

Once the cluster is up, login as the cluster administrator:

```shell
oc login -u system:admin
```

Now, we'll set up the default project for use with Knative.

```shell
oc project default

# SCCs (Security Context Constraints) are the precursor to the PSP (Pod
# Security Policy) mechanism in Kubernetes.
oc adm policy add-scc-to-user privileged -z default -n default

oc label namespace default istio-injection=enabled
```

## Installing Istio

Knative depends on Istio. First, run the following to grant the necessary
privileges to the service accounts istio will use:

```shell
oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z default -n istio-system
oc adm policy add-scc-to-user anyuid -z prometheus -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-egressgateway-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-citadel-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-ingressgateway-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-cleanup-old-ca-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-mixer-post-install-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-mixer-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z istio-sidecar-injector-service-account -n istio-system
oc adm policy add-cluster-role-to-user cluster-admin -z istio-galley-service-account -n istio-system
oc adm policy add-scc-to-user anyuid -z cluster-local-gateway-service-account -n istio-system
```

Run the following to install Istio:

```shell
curl -L https://storage.googleapis.com/knative-releases/serving/latest/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | oc apply -f -
```

Monitor the Istio components until all of the components show a `STATUS` of
`Running` or `Completed`:

```shell
oc get pods -n istio-system
```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

Set `priviledged` to `true` for the `istio-sidecar-injector`:

```shell
oc get cm istio-sidecar-injector -n istio-system -oyaml  \
| sed -e 's/securityContext:/securityContext:\\n      privileged: true/' \
| oc replace -f -
```

Restart the `sidecar-injector` pod if `SELinux` is enabled:

```shell
if getenforce | grep -q Disabled
then
    echo "SELinux is disabled, no need to restart the pod"
else
    echo "SELinux is enabled, restarting sidecar-injector pod"
    oc delete pod -n istio-system -l istio=sidecar-injector
fi
```

## Installing Knative Serving

Next, we'll install [Knative Serving](https://github.com/knative/serving).

First, run the following to grant the necessary privileges to the service
accounts istio will use:

```shell
oc adm policy add-scc-to-user anyuid -z build-controller -n knative-build
oc adm policy add-scc-to-user anyuid -z controller -n knative-serving
oc adm policy add-scc-to-user anyuid -z autoscaler -n knative-serving
oc adm policy add-scc-to-user anyuid -z kube-state-metrics -n knative-monitoring
oc adm policy add-scc-to-user anyuid -z node-exporter -n knative-monitoring
oc adm policy add-scc-to-user anyuid -z prometheus-system -n knative-monitoring
oc adm policy add-cluster-role-to-user cluster-admin -z build-controller -n knative-build
oc adm policy add-cluster-role-to-user cluster-admin -z controller -n knative-serving
```

Next, install Knative:

```shell
curl -L https://storage.googleapis.com/knative-releases/serving/latest/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | oc apply -f -
```

Monitor the Knative components until all of the components show a `STATUS` of
`Running`:

```shell
oc get pods -n knative-serving
```

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the command to see the current
status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

Now you can deploy an app to your newly created Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](getting-started-knative-app/)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../../serving/samples/) repo.

> Note: When looking up the IP address to use for accessing your app, you need
> to look up the NodePort for the `istio-ingressgateway` well as the IP
> address used for OpenShift. You can use the following command to look up the
> value to use for the {IP_ADDRESS} placeholder used in the samples:

```shell
# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

export IP_ADDRESS=$(oc get node  -o 'jsonpath={.items[0].status.addresses[0].address}'):$(oc get svc $INGRESSGATEWAY -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

## Cleaning up

Delete your test cluster by running:

```shell
oc cluster down
rm -rf openshift.local.clusterup
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
