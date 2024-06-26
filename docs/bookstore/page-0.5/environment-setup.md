# Environment Setup

![Image](images/image20.png)

In this page, we will be discussing how to set up your environment, and make sure to run up the UI front end and the Book Review Service’s node server.

## **What does the final deliverable for this section look like?**

- You have a running Kubernetes (k8s) cluster on your local machine, with Knative installed.
- You have your front end application deployed as Kubernetes deployment with port-forwarding to localhost:3000
- You have your Node.js application deployed as Kubernetes deployment with port-forwarding to localhost:8080

We will be fulfilling each requirement with the order above.

## **Clone the Repository**
![Next Step Image](images/image22.png)

```sh
git clone https://github.com/knative/docs.git
```
???+ bug "Troubleshooting"
    Having issue with cloning your repo? Check [here](https://docs.github.com/en/repositories/creating-and-managing-repositories/troubleshooting-cloning-errors){:target="_blank"} for help.

!!! warning

    **IMPORTANT**: Please take some time to read the [Disclaimer](../disclaimer/README.md){:target="_blank"} before moving to the next page.


## **File Structure**

![Image](images/image21.png)

The code for the sample app is in `docs/code-samples/eventing/bookstore-sample-app`

Under `bookstore-sample-app` folder, there are 2 folders:

* **/solution**: this folder contains all the yaml files, and the code you needed. Check it when you got stuck.

* **/start**: this folder contains the necessary files for you to get started. Save there all the configuration files yourself following the tutorial!

![Image](images/image16.png)

!!! tip
    Kuack suggests you to start from **/start**, write all the configuration files as you go over the tutorial, and check solutions when you got stuck.

![Image](images/image1.png)

Always `cd` back to the root directory, which is `/start`, before running any commands.

All the commands in the tutorial are written **assuming you are in the `/start` directory**.


## **Shortcut**

![Image](images/image10.png)

Running `docs/code-samples/eventing/bookstore-sample-app/start/setup.sh` will automatically complete all tasks in this section.

!!! warning

    However, if you are not familiar with the process, we recommend reviewing the steps below.

## **Instructions**

### **Task 1: Set Up a Running Kubernetes Cluster with Knative Installed**

![Image](images/image13.png)

Please follow the instructions [here](https://knative.dev/docs/install/){:target="_blank"} to spin up your cluster with Knative installed!

???+ success "Verify"

    You should see the pods in the `knative-eventing` and `knative-serving` namespaces running before proceeding.

    ```
    NAMESPACE          NAME                                      READY   STATUS    RESTARTS   AGE
    knative-eventing   eventing-controller-7576f555d5-7c2p2      1/1     Running   0          4m50s
    knative-eventing   eventing-webhook-5874bb8445-cqcn9         1/1     Running   0          4m50s
    knative-eventing   imc-controller-8c5d5ddb5-m249l            1/1     Running   0          4m49s
    knative-eventing   imc-dispatcher-76d9f7464b-dphd6           1/1     Running   0          4m49s
    knative-eventing   mt-broker-controller-8d8f8d48f-rvlcv      1/1     Running   0          4m48s
    knative-eventing   mt-broker-filter-85c457f879-dvhnj         1/1     Running   0          4m48s
    knative-eventing   mt-broker-ingress-5688f4cd68-nm8cc        1/1     Running   0          4m48s
    knative-serving    activator-55d856fccd-g5qpw                1/1     Running   0          4m53s
    knative-serving    autoscaler-5fb49c64c7-hrjng               1/1     Running   0          4m53s
    knative-serving    controller-ddbb9d4f-khttq                 1/1     Running   0          4m53s
    knative-serving    net-kourier-controller-68d89f78d5-hw8r6   1/1     Running   0          4m52s
    knative-serving    webhook-85b9744fc5-6w9sg                  1/1     Running   0          4m53s
    kourier-system     3scale-kourier-gateway-dbc5b88f5-7g29n    1/1     Running   0          4m52s
    kube-system        coredns-5dd5756b68-49xsj                  1/1     Running   0          12m
    kube-system        etcd-minikube                             1/1     Running   0          12m
    kube-system        kube-apiserver-minikube                   1/1     Running   0          12m
    kube-system        kube-controller-manager-minikube          1/1     Running   0          12m
    kube-system        kube-proxy-tqcvx                          1/1     Running   0          12m
    kube-system        kube-scheduler-minikube                   1/1     Running   0          12m
    kube-system        storage-provisioner                       1/1     Running   0          12m
    ```

#### **Extra Step for Minikube Users:**

![Image](images/image3.png)

Attention! In case you're not using the Knative Quick Start, set up the tunnel manually to connect to services of type `LoadBalancer`:

Run the following command and keep the terminal open:

```shell
minikube tunnel
```

???+ success "Verify"
    If there aren't any error messages, it means you have set up the tunnel successfully.

### **Task 2: Running the Bookstore Web App**

![Image](images/image12.png)

The Next.js frontend app is located in the `docs/code-samples/eventing/bookstore-sample-app/start/frontend` folder.

Ensure that port 3000 on your local machine is not being used by another application.

#### **Deploy the Frontend App**

You can either [build the image locally](https://docs.docker.com/get-started/02_our_app/){:target="_blank"} or use our pre-built image. If you are using the pre-built image, you can proceed to the next step.

When ready, run the following command to deploy the frontend app:

```shell
kubectl apply -f frontend/config/100-front-end-deployment.yaml
```

This will create the Deployment and expose it with a Service of type LoadBalancer to receive external traffic:

```
deployment.apps/bookstore-frontend created
service/bookstore-frontend-svc created
```

???+ success "Verify"
    Run the following command to check if the pod is running:
    
    ```shell
    kubectl get pods
    ```

    You will see that your front end pod is running.

    ```
    NAME                                  READY   STATUS    RESTARTS   AGE
    bookstore-frontend-7b879ffb78-9bln6   1/1     Running   0          4m37s
    ```



#### **Port Forwarding (Optional under condition)**

![Image](images/image9.png)

You might need to set up port forwarding to access the app from your local machine.

Check if port forwarding is necessary by running:

```shell
kubectl get services
```

And you will see the following console output:
```
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
bookstore-frontend-svc   LoadBalancer   10.99.187.173   <pending>     3000:31600/TCP   27m
kubernetes               ClusterIP      10.96.0.1       <none>        443/TCP          39m
```



!!! note
    If the `EXTERNAL-IP` for your frontend service is `127.0.0.1`, port forwarding is not needed.

If port forwarding is required, run the following command:

```shell
kubectl port-forward svc/bookstore-frontend-svc 3000:3000
```

You should see the following output:

```
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```


**Don't close the terminal when port-forwarding is established.** Start a new terminal to run the next command.

???+ success "Verify"

    Visit [http://localhost:3000](http://localhost:3000){:target="_blank"} in your browser. The UI page should appear!

    ![Image](images/image19.png)

### **Task 3: Running the Book Review Service**

![Image](images/image6.png)

The Node.js server is located in the `node-server` folder.

!!! warning

    Ensure that port 8080 on your local machine is not being used by another application.

#### **Deploy the Book Review Service: Node.js Server**

You can either [build the image locally](https://docs.docker.com/get-started/02_our_app/){:target="_blank"} or use our pre-built image. If you are using the pre-built image, you can proceed to the next step.

When ready, run the following command to deploy the Node.js server:

```shell
kubectl apply -f node-server/config/100-deployment.yaml
```

This command will pull the image and deploy it to your cluster as a Deployment. It will also expose it as a LoadBalancer to receive external traffic.

```
deployment.apps/node-server created
service/node-server-svc created
```

???+ success "Verify"

    Run the following command to check if the pod is running:

    ```shell
    kubectl get pods
    ```

    You will see that your Node.js server (node-server) pod is running.
    ```
    NAME                                  READY   STATUS    RESTARTS   AGE
    bookstore-frontend-7b879ffb78-9bln6   1/1     Running   0          39m
    node-server-68bf98cdf4-skjmh          1/1     Running   0          38m
    ```


#### **Port Forwarding (optional under condition)**

![Image](images/image9.png)

You might need to set up port forwarding to access the app from your local machine.

Check if port forwarding is necessary by running:

```shell
kubectl get services
```
And you will see the following console output:
```
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
bookstore-frontend-svc   LoadBalancer   10.99.187.173   <pending>     3000:31600/TCP   73m
kubernetes               ClusterIP      10.96.0.1       <none>        443/TCP          85m
node-server-svc          LoadBalancer   10.101.90.35    <pending>     80:31792/TCP     73m
```

!!! note
    If the `EXTERNAL-IP` for your Node.js service is `127.0.0.1`, port forwarding is not needed. If you failed to visit the page `localhost:8080`, you can try to set up port forwarding.

If port forwarding is required, open a new terminal and run:

```shell
kubectl port-forward svc/node-server-svc 8080:80
```
You should see the following output:

```
Forwarding from 127.0.0.1:8080 > 8000
Forwarding from [::1]:8080 > 8000
```

**Don't close the terminal when port-forwarding is established.** Start a new terminal to run the next command.


???+ success "Verify"

    Visit [http://localhost:8080](http://localhost:8080){:target="_blank"} in your browser. The Node.js service should be up and running.

    And in your front end page, you should see the status turns green and say "Connected to node server".

    ![Image](images/image18.png)

## **Troubleshooting**
If you encounter any issues during the setup process, refer to the troubleshooting section in the documentation or check the logs of your Kubernetes pods for more details.
???+ bug "Troubleshooting"

    To check the logs, use the following command:

    ```shell
    kubectl logs <pod-name>
    ```

    Replace `<pod-name>` with the name of the pod you want to check.

## **Next Step**
![Image](images/image5.png)

You have successfully set up the cluster with Knative installed, and running your front end app and node server. You are all set to start learning. Your journey begins from here.

[Go to Lesson 1 - Send Review Comment to Broker :fontawesome-solid-paper-plane:](../page-1/send-review-comment-to-broker.md){ .md-button .md-button--primary }
