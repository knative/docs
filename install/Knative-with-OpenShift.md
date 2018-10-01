# Knative Install on OpenShift

This guide walks you through the installation of the latest version of [Knative
Serving](https://github.com/knative/serving) on an
[OpenShift](https://github.com/openshift/origin) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](README.md).

## Before you begin

These instructions will run an OpenShift 3.10 (Kubernetes 1.10) cluster on your
local machine using [minishift](https://docs.okd.io/latest/minishift/getting-started/index.html)
to test-drive Knative.

## Configure and start minishift

The following details the bare minimum configuration required to setup minishift for running Knative:

```shell
minishift profile set knative
minishift config set memory 8GB
minishift config set cpus 4
minishift config set image-caching true
minishift addon enable admin-user
minishift addon enable anyuid
```

The above configuration ensures that Knative gets created in its own [minishift profile](https://docs.okd.io/latest/minishift/using/profiles.html) with 8GB of RAM and 4 vCpus. The image-caching helps in re-starting up the cluster faster every time.  The [addon](https://docs.okd.io/latest/minishift/using/addons.html) **admin-user** creates a default `admin` user with the role  cluster-admin and the  [addon](https://docs.okd.io/latest/minishift/using/addons.html) **anyuid** allows the `default` service account to run the application with uid `0`.

To start minishift:

```shell
minishift profile set knative
minishift start
```

The command `minishift profile set knative` is required every time you start and stop minishift to make sure that you are on right `knative` minishift profile that was configured above.

## Configuring `oc` (openshift cli)

Running the following command make sure that you have right version of `oc` and have configured the DOCKER daemon to be connected to minishift Docker.

```shell
eval $(minishift docker-env) && eval $(minishift oc-env)
```

## Preparing Knative Deployment

### Enable Admission Controller Webhook
To be able to deploy and run serverless Knative applications, its required that you must enable the [Admission Controller Webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/).  

Run the following command to make OpenShift (run via minishift) to be configured for [Admission Controller Webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/):

```shell
minishift openshift config set --target=kube --patch '{
    "admissionConfig": {
        "pluginConfig": {
            "ValidatingAdmissionWebhook": {
                "configuration": {
                    "apiVersion": "v1",
                    "kind": "DefaultAdmissionConfig",
                    "disable": false
                }
            },
            "MutatingAdmissionWebhook": {
                "configuration": {
                    "apiVersion": "v1",
                    "kind": "DefaultAdmissionConfig",
                    "disable": false
                }
            }
        }
    }
}'
```

Please allow few minutes for the OpenShift to be restarted.

### Configuring a OpenShift project

1. Since there was an `admin` addon added during minishift configuration, its now possible to login with the `admin` user. For example:

    ```shell
    oc login -u admin -p admin
    ```

2. Set up the project **myproject** for use with Knative applications.

    ```shell
    oc project myproject
    oc adm policy add-scc-to-user privileged -z myproject
    oc label namespace myproject istio-injection=enabled
    ```
    The `oc adm policy` adds the **privileged** [Security Context Constraints(SCCs)](https://docs.okd.io/3.10/admin_guide/manage_scc.html) to the **default** Service Account. The SCCs are the precursor to the PSP (Pod Security Policy) mechanism in Kubernetes.

    Its is also ensured that the project myproject is labelled for Istio automatic sidecar injection, with this `istio-injection=enabled` label to **myproject** each of the Knative applications that will be deployed in **myproject** will have Istio sidecars injected automatically. 

  > **IMPORTANT:** Avoid using `default` project in OpenShift for deploying Knative applications. As OpenShift deploys few of its mission critical applications in `default` project, its safe not to touch to avoid any crash to the OpenShift.

### Installing Istio

Knative depends on Istio. The [istio-openshift-policies.sh](scripts/istio-openshift-policies.sh) does run the required commands to configure necessary [privileges](https://istio.io/docs/setup/kubernetes/platform-setup/openshift/) to the service accounts used by Istio.

```shell
bash <(curl -s https://raw.githubusercontent.com/knative/docs/master/install/scripts/istio-openshift-policies.sh)
```

1. Run the following to install Istio:

    ```shell
    curl -L https://storage.googleapis.com/knative-releases/serving/latest/istio.yaml \
    | sed 's/LoadBalancer/NodePort/' \
    | oc apply -f -
    ```
2. Monitor the Istio components until all of the components show a `STATUS` of `Running` or `Completed`:

    ```shell
    oc get pods -n istio-system -w
    ```

> **NOTE:** It will take a few minutes for all the components to be up and running. Use CTRL+C to exit watch mode

**IMPORTANT:** Istio v1.0.1 change

> The Istio v1.0.1 release automatic sidecar injection has removed `privileged:true` from init contianers,this will cause the Pods with istio proxies automatic inject to crash. Run the following command to update the **istio-sidecar-injector** ConfigMap.

The following command ensures that the `privileged:true` is added to the **istio-sidecar-injector** ConfigMap:

```shell
oc get cm istio-sidecar-injector -n istio-system -oyaml  \
| sed -e 's/securityContext:/securityContext:\\n      privileged: true/' \
| oc replace -f -
```

## Install Knative Serving

The following section details on deploying [Knative Serving](https://github.com/knative/serving) to OpenShift.

The [knative-openshift-policies.sh](scripts/knative-openshift-policies.sh) runs the required commands to configure necessary [privileges] to the service accounts used by Knative.

```shell
bash <(curl -s https://raw.githubusercontent.com/knative/docs/master/install/scripts/knative-openshift-policies.sh)
```

1. Install Knative serving:

    ```shell
    curl -L https://storage.googleapis.com/knative-releases/serving/latest/release-lite.yaml \
    | sed 's/LoadBalancer/NodePort/' \
    | oc apply -f -
    ```

2. Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:

    ```shell
    oc get pods -n knative-serving -w
    oc get pods -n knative-build -w
    ```
    The first command watches for all pod status in `knative-serving` and the second command will watch for all pod status in `knative-build`.

> **NOTE:** It will take a few minutes for all the components to be up and running. Use CTRL+C to exit watch mode.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> Note: When looking up the IP address to use for accessing your app, you need to look up   the NodePort for the `knative-ingressgateway` as well as the IP address used for OpenShift. You can use the following command to look up the value to use for the {IP_ADDRESS} and {HOST_URL} placeholders  used in the samples:

  ```shell
  export IP_ADDRESS=$(kubectl get node -o 'jsonpath={.items[0].status.addresses[0].address}'):$(oc get svc knative-ingressgateway -n istio-system -o 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
  export HOST_URL=$(kubectl get  routes.serving.knative.dev <your-service-name>  -o jsonpath='{.status.domain}')
  ```

## Cleaning up

There are two ways to clean up, either deleting the entire minishift profile or only the respective projects.

1. Delete your test cluster by running:

    ```shell
    minishift stop
    minishift profile delete knative
    ```
2. Delete just Istio and Knative projects and applications:

   ```shell
    oc delete all --all  -n knative-build
    oc delete all --all  -n knative-serving
    oc delete all --all  -n istio-system
    oc delete all --all  -n myproject
    oc delete project knative-build
    oc delete project knative-serving
    oc delete project istio-system
   ```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
