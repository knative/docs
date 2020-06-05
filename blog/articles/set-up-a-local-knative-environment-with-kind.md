---
Title: 'How to set up a local Knative environment with KinD and without DNS headaches'
Author: Leon Stigter
Author handle: https://twitter.com/retgits
Date: ''
Description: A how-to guide to deploy Knative, Kourier, and your first app on top of a Kubernetes cluster.
Folder with media files: 'N/A'
Blog URL: ''
Labels: Articles
Reviewers: ''

---
| Reviewer  | Date | Approval |
| ------------- | ------------- | ------------- |
| @retgits  | 2020-06-03  |:+1:|
| <!-- Your Github handle here --> |   |  |

Knative builds on top of Kubernetes. For developers, it abstracts away complexity and enables them to focus on delivering value to their business. The complex, and sometimes boring, parts of building apps to run on Kubernetes are managed by Knative. Setting up a Kubernetes cluster and starting with Knative on your local machine can still be complex. In this post, let’s focus on setting up a lightweight environment to help you modern apps faster.

## KinD
If you want to create a Kubernetes cluster on your local machine, you have a bunch of options. Because you’re running containers in your Kubernetes cluster anyway, let’s also use containers for the actual cluster itself. Kubernetes IN Docker, or `kind` for short, enables developers to spin up a Kubernetes cluster where each “node” is a container.

You can install `kind` on your machine, by running the commands below:

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
```

The next step is to create a Kubernetes cluster using `kind`. While you can certainly use `kubectl port-forward` to get traffic into the cluster, a nicer way is to expose the ports the ingress gateway will listen on to the host. To do that, you can pass in a file with cluster configuration parameters:

```bash
cat > clusterconfig.yaml <<EOF
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
  extraPortMappings:
	## expose port 31380 of the node to port 80 on the host
  - containerPort: 31080
    hostPort: 80
	## expose port 31443 of the node to port 443 on the host
  - containerPort: 31443
    hostPort: 443
EOF
```

The values for the container ports are randomly chosen and are used later on to configure a NodePort service with these values. The values for the host ports are where you'll send cURL requests to as you deploy applications to the cluster.

With that cluster configuration file, you can create a cluster with the below command. Your `kubeconfig` will automatically be updated and the default cluster will be set to your new cluster.

```bash
$ kind create cluster --name knative --config clusterconfig.yaml
Creating cluster "knative" ...
 ✓ Ensuring node image (kindest/node:v1.18.2) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-knative"
You can now use your cluster with:

kubectl cluster-info --context kind-knative

Have a nice day! 👋
```

## Knative Serving
Now that the cluster is running, you can add the Knative components starting with Knative CRDs. At the time of writing the latest available version is `0.15`

```bash
$ kubectl apply --filename https://github.com/knative/serving/releases/download/v0.15.0/serving-crds.yaml

customresourcedefinition.apiextensions.k8s.io/certificates.networking.internal.knative.dev created
customresourcedefinition.apiextensions.k8s.io/configurations.serving.knative.dev created
customresourcedefinition.apiextensions.k8s.io/ingresses.networking.internal.knative.dev created
customresourcedefinition.apiextensions.k8s.io/metrics.autoscaling.internal.knative.dev created
customresourcedefinition.apiextensions.k8s.io/podautoscalers.autoscaling.internal.knative.dev created
customresourcedefinition.apiextensions.k8s.io/revisions.serving.knative.dev created
customresourcedefinition.apiextensions.k8s.io/routes.serving.knative.dev created
customresourcedefinition.apiextensions.k8s.io/serverlessservices.networking.internal.knative.dev created
customresourcedefinition.apiextensions.k8s.io/services.serving.knative.dev created
customresourcedefinition.apiextensions.k8s.io/images.caching.internal.knative.dev created
```

After the CRDs, the core components are next to be installed on your cluster. For brevity, the unchanged components are removed from the response.

```bash
$ kubectl apply --filename https://github.com/knative/serving/releases/download/v0.15.0/serving-core.yaml

namespace/knative-serving created
serviceaccount/controller created
clusterrole.rbac.authorization.k8s.io/knative-serving-admin created
clusterrolebinding.rbac.authorization.k8s.io/knative-serving-controller-admin created
image.caching.internal.knative.dev/queue-proxy created
configmap/config-autoscaler created
configmap/config-defaults created
configmap/config-deployment created
configmap/config-domain created
configmap/config-gc created
configmap/config-leader-election created
configmap/config-logging created
configmap/config-network created
configmap/config-observability created
configmap/config-tracing created
horizontalpodautoscaler.autoscaling/activator created
deployment.apps/activator created
service/activator-service created
deployment.apps/autoscaler created
service/autoscaler created
deployment.apps/controller created
service/controller created
deployment.apps/webhook created
service/webhook created
clusterrole.rbac.authorization.k8s.io/knative-serving-addressable-resolver created
clusterrole.rbac.authorization.k8s.io/knative-serving-namespaced-admin created
clusterrole.rbac.authorization.k8s.io/knative-serving-namespaced-edit created
clusterrole.rbac.authorization.k8s.io/knative-serving-namespaced-view created
clusterrole.rbac.authorization.k8s.io/knative-serving-core created
clusterrole.rbac.authorization.k8s.io/knative-serving-podspecable-binding created
validatingwebhookconfiguration.admissionregistration.k8s.io/config.webhook.serving.knative.dev created
mutatingwebhookconfiguration.admissionregistration.k8s.io/webhook.serving.knative.dev created
validatingwebhookconfiguration.admissionregistration.k8s.io/validation.webhook.serving.knative.dev created
```

## Networking
The next step is to choose a networking layer. While the docs have a lot of available options, Kourier is the option with the lowest resource requirements. Kourier connects to Envoy and the Knative Ingress CRDs directly.

To install Kourier and make it available as a service leveraging the node ports, you’ll need to download the YAML file first and make a few changes.

```bash
curl -Lo kourier.yaml https://github.com/knative/net-kourier/releases/download/v0.15.0/kourier.yaml
```

By default, the Kourier service is set to be of type LoadBalancer. On local machines, this type doesn’t work so you’ll have to change that to NodePort and add nodePort elements to the two listed ports. The complete Service portion (which runs from line 75 to line 94 in the document), should be replaced with:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kourier
  namespace: kourier-system
  labels:
    networking.knative.dev/ingress-provider: kourier
spec:
  ports:
  - name: http2
    port: 80
    protocol: TCP
    targetPort: 8080
    nodePort: 31080
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8443
    nodePort: 31443
  selector:
    app: 3scale-kourier-gateway
  type: NodePort
```

To install the Kourier controller, run:

```bash
$ kubectl apply --filename kourier.yaml

namespace/kourier-system created
configmap/config-logging created
configmap/config-observability created
configmap/config-leader-election created
service/kourier created
deployment.apps/3scale-kourier-gateway created
deployment.apps/3scale-kourier-control created
clusterrole.rbac.authorization.k8s.io/3scale-kourier created
serviceaccount/3scale-kourier created
clusterrolebinding.rbac.authorization.k8s.io/3scale-kourier created
service/kourier-internal created
service/kourier-control created
configmap/kourier-bootstrap created
```

The next step is to let Knative Serving know it should use Kourier as the default networking layer

```bash
$ kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

configmap/config-network patched
```

If you want to validate the patch command was successful, you can run:

```bash
$ kubectl describe configmap/config-network --namespace knative-serving
... (abbreviated for readability)
ingress.class:
----
kourier.ingress.networking.knative.dev
...
```

To get the same experience as with a full-blown cluster that has DNS names set up, you can add a “magic” DNS provider. In this case, `nip.io` provides a wildcard DNS setup that will automatically resolve to the IP address you put in front of  `nip.io`. To patch the domain configuration for Knative Serving to make use of `nip.io`, you can run:

```bash
$ kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"127.0.0.1.nip.io":""}}'
configmap/config-domain patched
```

If you want to validate the patch command was successful, you can run:

```bash
$ kubectl describe configmap/config-domain --namespace knative-serving
... (abbreviated for readability)
Data
====
127.0.0.1.nip.io:
----
...
```

By now, all pods in the knative-serving and kourier-system namespaces should be running:

```bash
$ kubectl get pods --namespace knative-serving
NAME                          READY   STATUS    RESTARTS   AGE
activator-6d9f95b7f8-w6m68    1/1     Running   0          12m
autoscaler-597fd8d69d-gmh9s   1/1     Running   0          12m
controller-7479cc984d-492fm   1/1     Running   0          12m
webhook-bf465f954-4c7wq       1/1     Running   0          12m

$ kubectl get pods --namespace kourier-system
NAME                                      READY   STATUS    RESTARTS   AGE
3scale-kourier-control-699cbc695-ztswk    1/1     Running   0          10m
3scale-kourier-gateway-7df98bb5db-5bw79   1/1     Running   0          10m
```

To validate your cluster gateway is in the right state and using the right ports, you can run:

```bash
$ kubectl --namespace kourier-system get service kourier
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kourier   NodePort   10.98.179.178   <none>        80:31080/TCP,443:31443/TCP   87m

$ docker ps -a
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                                                                      NAMES
d53c275d7461        kindest/node:v1.18.2   "/usr/local/bin/entr…"   4 hours ago         Up 4 hours          127.0.0.1:49350->6443/tcp, 0.0.0.0:80->31080/tcp, 0.0.0.0:443->31443/tcp   knative-control-plane
```

The ports, and how they’re tied to the host, should be the same as you’ve defined in the clusterconfig file. For example, port 31380 in the cluster is exposed as port 80.

## Your first app
Everyone enjoys a good “hello world” example as the first app you deploy, so let’s do that here too. The cluster, Knative, and the networking components are ready so the last part is to deploy an app. The straightforward [Go app](https://knative.dev/docs/eventing/samples/helloworld/helloworld-go/) that already exists, is an excellent candidate to deploy. The first step there is to create a yaml file with the hello world service definition.

```bash
cat > service.yaml <<EOF
apiVersion: serving.knative.dev/v1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go # The URL to the image of the app
          env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Hello Knative Serving is up and running with Kourier!!"
EOF
```

To deploy your app to Knative, run

```bash
$ kubectl apply --filename service.yaml
service.serving.knative.dev/helloworld-go created
```

To validate your deployment, you can use  `kubectl get ksvc`. While your cluster is taking care of the configuration of the different elements that make up the service the output of that command will show that the revision is missing. After some time, you’ll see *ready* change to true.

```bash
$ kubectl get ksvc
NAME            URL                                             LATESTCREATED         LATESTREADY   READY     REASON
helloworld-go   http://helloworld-go.default.127.0.0.1.nip.io   helloworld-go-fqqs6                 Unknown   RevisionMissing

$ kubectl get ksvc
NAME            URL                                             LATESTCREATED         LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.127.0.0.1.nip.io   helloworld-go-fqqs6   helloworld-go-fqqs6   True
```

A running and ready service leaves one final step… checking that the code returns what you expect. To do that, you can send a cURL request to the URL listed above. Because you’ve mapped port 80 of the host to be forwarded to the cluster, and set the DNS, you can use that exact URL.

```bash
$ curl -v http://helloworld-go.default.127.0.0.1.nip.io
Hello Knative Serving is up and running with Kourier!!
```

## Cleaning up
To stop your cluster and remove all the resources you’ve created, you can run the below command:

```bash
kind delete cluster --name knative
Deleting cluster "knative" ...
```

## About the author
As a Product Manager, Leon is very passionate and outspoken when it comes to serverless and container technologies. He believes that "devs wanna dev" and that drives his passion to help build better products. He enjoys writing code, speaking at conferences and meetups, and blogging about that.
In his personal life, he’s on a mission to taste cheesecake in every city he visits (suggestions are welcome @retgits).
