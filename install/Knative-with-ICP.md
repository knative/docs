# Knative Install on IBM Cloud Private

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample `hello world` app onto
the newly created Knative cluster.

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires an [IBM Cloud Private](https://www.ibm.com/cloud/private) cluster v3.1.1. See [Installing IBM Cloud Private Cloud Native, Enterprise, and Community editions]((https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/install_containers.html)) in the IBM Knowledge Center for install instructions.

### Step 1: Install Docker for your boot node only

The boot node is the node that is used for installation of your cluster. The boot node is usually your master node. For more information about the [boot node](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/getting_started/architecture.html#boot), see Boot node. You need a version of Docker that is supported by IBM Cloud Private installed on your boot node. See [Supported Docker versions](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/supported_system_config/supported_docker.html). To install Docker, see [Manually installing Docker](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/install_docker.html#manual).

### Step 2: Set up the installation environment

1. Log in to the boot node as a user with root permissions.

2. Obtain the installation file or image:

   For IBM Cloud Private only: Download the installation files for IBM Cloud Private. You must download the correct file or files for the type of nodes in your cluster. You can obtain these files from the [IBM Passport Advantage®](https://www.ibm.com/software/passportadvantage/) Opens in a new tab website.

   For a Linux® 64-bit cluster, download the ibm-cloud-private-x86_64-3.1.1.tar.gz file.
   For a Linux® on Power® (ppc64le) cluster, download the ibm-cloud-private-ppc64le-3.1.1.tar.gz file.
   For a cluster that uses IBM® Z worker and proxy nodes, download the ibm-cloud-private-s390x-3.1.1.tar.gz file.

3. For IBM Cloud Private only: Extract the images and load them into Docker. Extracting the images might take a few minutes.
    For Linux® 64-bit, run this command:
    ```
    tar xf ibm-cloud-private-x86_64-3.1.1.tar.gz -O | sudo docker load
    ```
    For Linux® on Power® (ppc64le), run this command:
    ```
    tar xf ibm-cloud-private-ppc64le-3.1.1.tar.gz -O | sudo docker load
    ```

4. Create an installation directory to store the IBM Cloud Private configuration files in and change to that directory. For example, to store the configuration files in /opt/ibm-cloud-private-3.1.1, run the following commands:
    ```
    sudo mkdir /opt/ibm-cloud-private-3.1.1;
    cd /opt/ibm-cloud-private-3.1.1
    ```

5. Extract the configuration files from the installer image.

   For Linux® 64-bit, run this command:

        sudo docker run -v $(pwd):/data -e LICENSE=accept \
        ibmcom/icp-inception-amd64:3.1.1-ee \
        cp -r cluster /data
        
   For Linux® on Power® (ppc64le), run this command:

        sudo docker run -v $(pwd):/data -e LICENSE=accept \
        ibmcom/icp-inception-ppc64le:3.1.1-ee \
        cp -r cluster /data

6. (Optional) You can view the license file for IBM Cloud Private.

    For Linux® 64-bit, run this command:

        sudo docker run -e LICENSE=view -e LANG=$LANG ibmcom/icp-inception-amd64:3.1.1-ee

    For Linux® on Power® (ppc64le), run this command:

        sudo docker run -e LICENSE=view -e LANG=$LANG ibmcom/icp-inception-ppc64le:3.1.1-ee

7. Create a secure connection from the boot node to all other nodes in your cluster. Complete one of the following processes:
    Set up SSH in your cluster. See [Sharing SSH keys among cluster nodes](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/ssh_keys.html).
    Set up password authentication in your cluster. See [Configuring password authentication for cluster nodes](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/password_auth.html).

8. Add the IP address of each node in the cluster to the /<installation_directory>/cluster/hosts file. See [Setting the node roles in the hosts file](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/hosts.html). You can also define customized host groups, see [Defining custom host groups](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/hosts.html#hostgroup).

    > Note: For IBM Cloud Private: Worker nodes can support mixed architectures. You can add worker nodes into a single cluster that run on Linux® 64-bit, Linux® on Power® (ppc64le) and IBM® Z platforms.
  
   For IBM Cloud Private-CE: Worker and proxy nodes can support mixed architectures. You do not need to download or pull any platform specific packages to set up a mixed architecture worker or proxy environment for IBM Cloud Private-CE. To add worker or proxy nodes into a cluster that contains Linux® 64-bit, Linux® on Power® (ppc64le) and IBM® Z platforms, you need to add the IP address of these nodes to the /<installation_directory>/cluster/hosts file only.

9. If you use SSH keys to secure your cluster, in the /<installation_directory>/cluster folder, replace the ssh_key file with the private key file that is used to communicate with the other cluster nodes. See [Sharing SSH keys among cluster nodes](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/ssh_keys.html). Run this command:

   ```
   sudo cp ~/.ssh/id_rsa ./cluster/ssh_key
   ```
  
   In this example, ~/.ssh/id_rsa is the location and name of the private key file.

10. For IBM Cloud Private only: Move the image files for your cluster to the /<installation_directory>/cluster/images folder.

    Create an images directory:
    ```
    mkdir -p cluster/images;
    ```
    If your cluster contains the x86_64 node, place the x86 package in the images directory:
    ```
    sudo mv /<path_to_installation_file>/ibm-cloud-private-x86_64-3.1.1.tar.gz  cluster/images/
    ```
    If your cluster contains the ppc64le node, place the ppc64le package in the images directory:
    ```
    sudo mv /<path_to_installation_file>/ibm-cloud-private-ppc64le-3.1.1.tar.gz  cluster/images/
    ```
    If your cluster contains the s390x node, place the s390x package in the images directory:
    ```
    sudo mv /<path_to_installation_file>/ibm-cloud-private-s390x-3.1.1.tar.gz  cluster/images/
    ```
    
    In these command, path_to_installation_file is the path to the images file.

### Step 3: Customize your cluster

1. Set up resource limits for proxy nodes. See [Configuring process resource limit on proxy nodes](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/proxy_resource.html).

2. You can also set a variety of optional cluster customizations that are available in the /<installation_directory>/cluster/config.yaml file. See [Customizing the cluster with the config.yaml file](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/config_yaml.html). For additional customizations, you can also review [Customizing your installation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/custom_install.html).

3. In an environment that has multiple network interfaces (NICs), such as OpenStack and AWS, you must add the following code to the config.yaml file:

    For IBM Cloud Private:

    ```
    cluster_lb_address: <external address>
    proxy_lb_address: <external address>
    ```

### Step 4: Set up Docker for your cluster nodes

Cluster nodes are the master, worker, proxy, and management nodes. See, [Architecture](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/getting_started/architecture.html). You need a version of Docker that is supported by IBM Cloud Private installed on your cluster node. See [Supported Docker versions](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/supported_system_config/supported_docker.html). If you do not have supported version of Docker installed on your cluster nodes, IBM Cloud Private can automatically install Docker on your cluster nodes during the installation. To prepare your cluster nodes for automatic installation of Docker, see [Configuring cluster nodes for automatic Docker installation](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/docker_cluster.html).

### Step 5: Deploy the environment

1. Change to the cluster folder in your installation directory.
    ```
     cd ./cluster
    ```

2. Deploy your environment. Depending on your options, you might need to add more parameters to the deployment command.

   For IBM Cloud Private only: If you had specified the offline_pkg_copy_path parameter in the config.yaml file. In the deployment command, add the -e ANSIBLE_REMOTE_TEMP=<offline_pkg_copy_path> option, where <offline_pkg_copy_path> is the value of the offline_pkg_copy_path parameter that you set in the config.yaml file.

   By default, the command to deploy your environment is set to deploy 15 nodes at a time. If your cluster has more than 15 nodes, the deployment might take a longer time to finish. If you want to speed up the deployment, you can specify a higher number of nodes to be deployed at a time. Use the argument -f \<number of nodes to deploy\> with the command.

   To deploy your environment:

   For Linux® 64-bit, run this command:

    ```
    sudo docker run --net=host -t -e LICENSE=accept \
    -v "$(pwd)":/installer/cluster ibmcom/icp-inception-amd64:3.1.1-ee install
    ```

   For Linux® on Power® (ppc64le), run this command:

    ```
    sudo docker run --net=host -t -e LICENSE=accept \
    -v "$(pwd)":/installer/cluster ibmcom/icp-inception-ppc64le:3.1.1-ee install
    ```

## Installing Istio

Follow the [instructions](https://istio.io/docs/setup/kubernetes/quick-start-ibm/#ibm-cloud-private) to install and run Istio in [IBM Cloud Private](https://www.ibm.com/cloud/private).

## Installing Knative Serving

Next, install [Knative Serving](https://github.com/knative/serving):

```
curl -L https://github.com/knative/serving/releases/download/v0.2.2/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

If the `image-security-enforcement` enabled when you install [IBM Cloud Private](https://www.ibm.com/cloud/private). You need to update the [image security policy](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/image_security.html) allow to pull the knative image.
Using the following commend get the image security policy.
```
kubectl get clusterimagepolicies
NAME                                    AGE
ibmcloud-default-cluster-image-policy   27m
```

Then edit the image security policy.
```
kubectl edit clusterimagepolicies ibmcloud-default-cluster-image-policy
```

Update spec.repositories by adding `gcr.io/knative-releases/*`
```
spec:
  repositories:
  - name: "gcr.io/knative-releases/*"
```

Put the namespaces `knative-serving`, `knative-build`, `knative-monitoring` and `knative-eventing` into pod security policy `ibm-privileged-psp` as follows.

The pod security policy in [IBM Cloud Private](https://www.ibm.com/cloud/private) as follows:
```
kubectl get psp
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
The output resembles the following code:
```
clusterrole "knative-role" created
```

Set up cluster role binding for the service account in knative namespace. By using this role binding, you can set the service accounts in the namespace to use the pod security policy that you created.
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

You can use the same mothed add the other knative namespaces to `ibm-privileged-psp` pod security policy.

Monitor the Knative components until all of the components show a `STATUS` of
`Running`:

```
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
  echo $(ICP cluster ip):$(kubectl get svc knative-ingressgateway --namespace istio-system \
  --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
  ```

## Cleaning up

Delete the cluster on [IBM Cloud Private](https://www.ibm.com/cloud/private):

```shell
curl -L https://github.com/knative/serving/releases/download/v0.2.2/release-lite.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl delete --filename -
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
