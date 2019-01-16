# Knative Install on IBM Cloud Private

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) and
[Knative Build](https://github.com/knative/build) using pre-built images and
demonstrates creating and deploying an image of a sample `hello world` app onto
the newly created Knative cluster on
[IBM Cloud Private](https://www.ibm.com/cloud/private).

You can find [guides for other platforms here](README.md).

## Before you begin

### Install IBM Cloud Private

Knative requires a v3.1.1 standard
[IBM Cloud Private](https://www.ibm.com/cloud/private) cluster. Before you can
install Knative, you must first complete all the steps that are provided in the
[IBM Cloud Private standard cluster installation instructions](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/install_containers.html).
For Example:

1. Install Docker for your boot node only

2. Set up the installation environment

3. Customize your cluster

4. Set up Docker for your cluster nodes

5. Deploy the environment

6. Verify the status of your installation

### Configure IBM Cloud Private security policies

You need to create and set both the image security and pod security policies
before you install Knative in your cluster.

#### Update the image security policy

Update the
[image security policy (`image-security-enforcement`)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/image_security.html)
in IBM Cloud Private to allow the access to the Knative image:

1. Edit the image security policy:

   ```
   kubectl edit clusterimagepolicies ibmcloud-default-cluster-image-policy
   ```

2. Update `spec.repositories` by adding `"gcr.io/knative-releases/*"`, for
   example:
   ```yaml
   spec:
     repositories:
       - name: "gcr.io/knative-releases/*"
   ```

#### Update pod security policy

Configure the namespaces `knative-serving` into pod security policy
`ibm-privileged-psp`. The step as follows:

1. Create a cluster role for the pod security policy resource. The resourceNames
   for this role must be the name of the pod security policy that was created
   previous. Here we use `ibm-privileged-psp`. Run the following command:

   ```shell
   cat <<EOF | kubectl apply -f -
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
   EOF
   ```

2. In the Knative installation steps below, you have the option of installing a
   Knative installation bundle or individual components. For each component that
   you install, you must create a cluster role binding between the service
   account of the Knative namespace and the `ibm-privileged-psp` pod security
   policy that you created.

   For example to create a role binding for the `knative-serving` namespace, run
   the following command:

   ```shell
   cat <<EOF | kubectl apply -f -
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
   EOF
   ```

**Important**: If you choose to install the Knative Build or observability
plugin, you must also create cluster role bindings for the service accounts in
the`knative-build` and `knative-monitoring` namespaces.

## Installing Istio

[Follow the instructions to install and run Istio in IBM Cloud Private](https://istio.io/docs/setup/kubernetes/quick-start-ibm/#ibm-cloud-private).

## Installing Knative components

You can install the Knative Serving, Knative Build and Knative Monitoring
components together, or individually.

1. Run one of the following commands to install Knative:

   - To install the [Knative Serving](https://github.com/knative/serving) and
     [Knative Build](https://github.com/knative/build) components with metrics
     and monitoring, enter the following commands:

     ```shell
     curl -L https://github.com/knative/serving/releases/download/v0.3.0/serving.yaml \
       | sed 's/LoadBalancer/NodePort/' \
       | kubectl apply --filename -

     curl -L https://github.com/knative/build/releases/download/v0.3.0/build.yaml \
       | sed 's/LoadBalancer/NodePort/' \
       | kubectl apply --filename -

     curl -L https://github.com/knative/serving/releases/download/v0.3.0/monitoring.yaml \
       | sed 's/LoadBalancer/NodePort/' \
       | kubectl apply --filename -
     ```
     See [Installing logging, metrics, and traces](../serving/installing-logging-metrics-traces.md)
     for details about installing the various supported observability plug-ins.

   - To install only [Knative Serving](https://github.com/knative/serving),
     enter the following command:

     ```shell
     curl -L https://github.com/knative/serving/releases/download/v0.3.0/serving.yaml \
       | sed 's/LoadBalancer/NodePort/' \
       | kubectl apply --filename -
     ```

   - To install only [Knative Build](https://github.com/knative/build),
     enter the following command:

     ```shell
     curl -L https://github.com/knative/build/releases/download/v0.3.0/build.yaml \
       | sed 's/LoadBalancer/NodePort/' \
       | kubectl apply --filename -
     ```

1. Depending on which Knative components you chose to install, ensure that the
   installation is successful by running the following commands until the
   namespace shows a `STATUS` of `Running`:

   ```
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-build
   kubectl get pods --namespace knative-monitoring
   ```

   > Note: Instead of rerunning the command, you can add `--watch` to the above
   > command to view the component's status updates in real time. Use CTRL+C to
   > exit watch mode.

Now you can deploy an app to your newly created Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

_Note_: When looking up the IP address to use for accessing your app, you need
to look up the NodePort for the `knative-ingressgateway` as well as the IP
address used for ICP. You can use the following command to look up the value to
use for the {IP_ADDRESS} placeholder used in the samples:

```shell
echo $(ICP cluster ip):$(kubectl get svc knative-ingressgateway --namespace istio-system \
--output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

## Cleaning up

To remove Knative from your IBM Cloud Private cluster by running one of the
following commands:

- If you installed the Knative Serving, run:

  ```shell
  curl -L https://github.com/knative/serving/releases/download/v0.3.0/serving.yaml \
    | sed 's/LoadBalancer/NodePort/' \
    | kubectl delete --filename -
  ```

- If you installed Knative Build, run:
  ```shell
  curl -L https://github.com/knative/build/releases/download/v0.3.0/build.yaml \
    | sed 's/LoadBalancer/NodePort/' \
    | kubectl delete --filename -
  ```

- If you installed Knative monitoring and metrics, run:
  ```shell
  curl -L https://github.com/knative/serving/releases/download/v0.3.0/monitoring.yaml \
    | sed 's/LoadBalancer/NodePort/' \
    | kubectl delete --filename -
  ```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
