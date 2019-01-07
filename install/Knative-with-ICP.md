# Knative Install on IBM Cloud Private

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) and [Knative Build](https://github.com/knative/build) using pre-built images and
demonstrates creating and deploying an image of a sample `hello world` app onto
the newly created Knative cluster on [IBM Cloud Private](https://www.ibm.com/cloud/private).

You can find [guides for other platforms here](README.md).

## Before you begin

### Install IBM Cloud Private

Knative requires a v3.1.1 standard [IBM Cloud Private](https://www.ibm.com/cloud/private) cluster. Before you can install Knative, you must first complete all the steps that are provided in the [IBM Cloud Private standard cluster installation instructions](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/install_containers.html).

1. Install Docker for your boot node only

2. Set up the installation environment

3. Customize your cluster

4. Set up Docker for your cluster nodes

5. Deploy the environment

6. Verify the status of your installation


### Update the image security policy
You need to update the [image security policy](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/image_security.html) to allow the cluster to pull the Knative image when you enable the `image-security-enforcement` at the time of [IBM Cloud Private](https://www.ibm.com/cloud/private) installation.

1. Edit the image security policy.
    ```
    kubectl edit clusterimagepolicies ibmcloud-default-cluster-image-policy
    ```

2. Update `spec.repositories` by adding `"gcr.io/knative-releases/*"`
    ```yaml
    spec:
      repositories:
      - name: "gcr.io/knative-releases/*"
    ```

### Update pod security policy
Configure the namespaces `knative-serving` into pod security policy `ibm-privileged-psp`. The step as follows:

1. Create a cluster role for the pod security policy resource. The resourceNames for this role must be the name of the pod security policy that was created previous. Here we use `ibm-privileged-psp`. Run the following command:
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

2. Set up cluster role binding for the service account in Knative namespace. By using this role binding, you can set the service accounts in the namespace to use the pod security policy that you created.
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

3. If you have the `knative-build` and `knative-monitoring` namespaces, use the same method to add the namespaces to the `ibm-privileged-psp` pod security policy.

## Installing Istio

[Follow the instructions to install and run Istio in IBM Cloud Private](https://istio.io/docs/setup/kubernetes/quick-start-ibm/#ibm-cloud-private).

## Installing Knative components

You can install the Knative Serving, Knative Build and Knative Monitoring components together, or individually.

### Installing Knative Serving, Knative Build and Knative Monitoring components

Run the following command to deploy [Knative Serving](https://github.com/knative/serving) and [Knative Build](https://github.com/knative/build)

```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

### Installing Knative Serving only

Replace `release-lite.yaml` to `serving.yaml` file, the other steps are all the same as above.

```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/serving.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

### Installing Knative Build only

Replace `release-lite.yaml` to `build.yaml` file, the other steps are all the same as above.

```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/build.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

Ensure that the installation was successful by running the following commands until both of the Knative components show a `STATUS` of `Running`:

    ```
    kubectl get pods --namespace knative-serving
    kubectl get pods --namespace knative-build
    ```

   It might take a few seconds for the Knative.

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

*Note*: When looking up the IP address to use for accessing your app, you need to look up
  the NodePort for the `knative-ingressgateway` as well as the IP address used for ICP.
  You can use the following command to look up the value to use for the {IP_ADDRESS} placeholder
  used in the samples:
  ```shell
  echo $(ICP cluster ip):$(kubectl get svc knative-ingressgateway --namespace istio-system \
  --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
  ```

## Cleaning up

Delete the cluster on [IBM Cloud Private](https://www.ibm.com/cloud/private):

If you use the `release-lite.yaml` to install. The clean command as follows:
```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl delete --filename -
```

If you use the `serving.yaml` to install. The clean command as follows:
```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/serving.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl delete --filename -
```

If you use the `build.yaml` to install. The clean command as follows:
```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/build.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl delete --filename -
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
