---
title: "Install on OpenShift"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 10
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) on an
[OpenShift](https://github.com/openshift/origin) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](../).

## Minishift setup

- Setup minishift based instructions from
  https://docs.okd.io/latest/minishift/getting-started/index.html

- Ensure `minishift` is setup correctly by running the command:

```shell
# returns minishift v1.26.1+1e20f27
minishift version
```

## Configure and start minishift

The following details the bare minimum configuration required to setup minishift
for running Knative:

```shell

# make sure you have  a profile is set correctly, e.g. knative
minishift profile set knative

# minimum memory required for the minishift VM
minishift config set memory 8GB

# the minimum required vCpus for the minishift vm
minishift config set cpus 4

# extra disk size for the vm, default is 20GB
minishift config set disk-size 50GB

# caching the images that will be downloaded during app deployments
minishift config set image-caching true

# Add new user called admin with password admin having role cluster-admin
minishift addons enable admin-user

# Allow the containers to be run with uid 0
minishift addons enable anyuid

# start minishift
minishift start
```

- The above configuration ensures that Knative gets created in its own
  [minishift profile](https://docs.okd.io/latest/minishift/using/profiles.html)
  called `knative` with 8GB of RAM, 4 vCpus and 50GB of hard disk. The
  image-caching helps in re-starting up the cluster faster every time.
- The [addon](https://docs.okd.io/latest/minishift/using/addons.html)
  **admin-user** creates a user called `admin` with password `admin` having the
  role of cluster-admin. The user gets created only after the addon is applied,
  that is usually after successful start of Minishift
- The [addon](https://docs.okd.io/latest/minishift/using/addons.html) **anyuid**
  allows the `default` service account to run the application with uid `0`

- The command `minishift profile set knative` is required every time you start
  and stop minishift to make sure that you are on right `knative` minishift
  profile that was configured above.

## Configuring `oc` (openshift cli)

Running the following command make sure that you have right version of `oc` and
have configured the DOCKER daemon to be connected to minishift docker.

```shell
# configures the host talk to DOCKER daemon of minishift
minishift docker-env
# Adds the right version of openshift cli binary to $PATH
minishift oc-env
```

## Preparing Knative Deployment

### Enable Admission Controller Webhook

To be able to deploy and run serverless Knative applications, its required that
you must enable the
[Admission Controller Webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/).

Run the following command to make OpenShift (run via minishift) to be configured
for
[Admission Controller Webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/):

```shell
# Enable admission controller webhooks
# The configuration stanzas below look weird and are just to workaround for:
# https://bugzilla.redhat.com/show_bug.cgi?id=1635918
minishift openshift config set --target=kube --patch '{
    "admissionConfig": {
        "pluginConfig": {
            "ValidatingAdmissionWebhook": {
                "configuration": {
                    "apiVersion": "apiserver.config.k8s.io/v1alpha1",
                    "kind": "WebhookAdmission",
                    "kubeConfigFile": "/dev/null"
                }
            },
            "MutatingAdmissionWebhook": {
                "configuration": {
                    "apiVersion": "apiserver.config.k8s.io/v1alpha1",
                    "kind": "WebhookAdmission",
                    "kubeConfigFile": "/dev/null"
                }
            }
        }
    }
}'

# wait until the kube-apiserver is restarted
until oc login -u admin -p admin; do sleep 5; done;
```

### Configuring a OpenShift project

1. Set up the project **myproject** for use with Knative applications.

   ```shell
   oc project myproject
   oc adm policy add-scc-to-user privileged -z default
   oc label namespace myproject istio-injection=enabled
   ```

   The `oc adm policy` adds the **privileged**
   [Security Context Constraints(SCCs)](https://docs.okd.io/3.10/admin_guide/manage_scc.html)
   to the **default** Service Account. The SCCs are the precursor to the PSP
   (Pod Security Policy) mechanism in Kubernetes, as isito-sidecars required to
   be run with **privileged** permissions you need set that here.

   Its is also ensured that the project myproject is labelled for Istio
   automatic sidecar injection, with this `istio-injection=enabled` label to
   **myproject** each of the Knative applications that will be deployed in
   **myproject** will have Istio sidecars injected automatically.

> **IMPORTANT:** Avoid using `default` project in OpenShift for deploying
> Knative applications. As OpenShift deploys few of its mission critical
> applications in `default` project, it's safer not to touch it to avoid any
> instabilities in OpenShift.

### Installing Istio

Knative depends on Istio. The
[istio-openshift-policies.sh](scripts/istio-openshift-policies.sh) does run the
required commands to configure necessary
[privileges](https://istio.io/docs/setup/kubernetes/platform-setup/openshift/)
to the service accounts used by Istio.

```shell
curl -s https://raw.githubusercontent.com/knative/docs/master/install/scripts/istio-openshift-policies.sh | bash
```

1. Run the following to install Istio:

   ```shell
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.3.0/istio-crds.yaml && \
   oc apply -f https://github.com/knative/serving/releases/download/v0.3.0/istio.yaml
   ```
   Note: the resources (CRDs) defined in the `istio-crds.yaml`file are
   also included in the `istio.yaml` file, but they are pulled out so that
   the CRD definitions are created first. If you see an error when creating
   resources about an unknown type, run the second `kubectl apply` command
   again.

2. Ensure the istio-sidecar-injector pods runs as provileged:
   ```shell
   oc get cm istio-sidecar-injector -n istio-system -oyaml | sed -e 's/securityContext:/securityContext:\\n      privileged: true/' | oc replace -f -
   ```
3. Monitor the Istio components until all of the components show a `STATUS` of
   `Running` or `Completed`:
   `shell while oc get pods -n istio-system | grep -v -E "(Running|Completed|STATUS)"; do sleep 5; done`
   > **NOTE:** It will take a few minutes for all the components to be up and
   > running.

## Install Knative Serving

The following section details on deploying
[Knative Serving](https://github.com/knative/serving) to OpenShift.

The [knative-openshift-policies.sh](scripts/knative-openshift-policies.sh) runs
the required commands to configure necessary privileges to the service accounts
used by Knative.

```shell
curl -s https://raw.githubusercontent.com/knative/docs/master/install/scripts/knative-openshift-policies.sh | bash
```

> You can safely ignore the warnings:

- Warning: ServiceAccount 'build-controller' not found cluster role
  "cluster-admin" added: "build-controller"
- Warning: ServiceAccount 'controller' not found cluster role "cluster-admin"
  added: "controller"

1. Install Knative serving:

   ```shell
   oc apply -f https://github.com/knative/serving/releases/download/v0.3.0/serving.yaml \
   oc apply -f https://github.com/knative/build/releases/download/v0.3.0/build.yaml
   ```

2. Monitor the Knative components until all of the components show a `STATUS` of
   `Running` or `Completed`:

   ```shell
   while oc get pods -n knative-build | grep -v -E "(Running|Completed|STATUS)"; do sleep 5; done
   while oc get pods -n knative-serving | grep -v -E "(Running|Completed|STATUS)"; do sleep 5; done
   ```

   The first command watches for all pod status in `knative-build` and the
   second command will watch for all pod status in `knative-serving`.

   > **NOTE:** It will take a few minutes for all the components to be up and
   > running.

3. Set route to access the OpenShift ingress CIDR, so that services can be
   accessed via LoadBalancerIP
   ```shell
   # Only for macOS
   sudo route -n add -net $(minishift openshift config view | grep ingressIPNetworkCIDR | awk '{print $NF}') $(minishift ip)
   # Only for Linux
   sudo ip route add $(minishift openshift config view | grep ingressIPNetworkCIDR | sed 's/\r$//' | awk '{print $NF}') via $(minishift ip)
   ```

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

1. Deploy sample HelloWorld app:

```shell
oc project myproject
echo '
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
            env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Go Sample v1"
' | oc create -f -
# Wait for the hello pod to enter its `Running` state
oc get pod --watch

# In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
INGRESSGATEWAY=knative-ingressgateway

# The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
# Use `istio-ingressgateway` instead, since `knative-ingressgateway`
# will be removed in Knative v0.4.
if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
    INGRESSGATEWAY=istio-ingressgateway
fi

# Call the service
export IP_ADDRESS=$(oc get svc $INGRESSGATEWAY -n istio-system -o 'jsonpath={.status.loadBalancer.ingress[0].ip}')
# This should output 'Hello World: Go Sample v1!'
curl -H "Host: helloworld-go.myproject.example.com" http://$IP_ADDRESS
```

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../../serving/samples/) repository.

## Cleaning up

There are two ways to clean up, either deleting the entire minishift profile or
only the respective projects.

1. Delete just Istio and Knative projects and applications:

   ```shell
    oc delete all --all  -n knative-build
    oc delete all --all  -n knative-serving
    oc delete all --all  -n istio-system
    oc delete all --all  -n myproject
    oc delete project knative-build
    oc delete project knative-serving
    oc delete project istio-system
   ```

2. Delete your test cluster by running:

   ```shell
   minishift stop
   minishift profile delete knative
   ```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
