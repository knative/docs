# Knative Serving in k0s

**Author: [Naveenraj Muthuraj](https://twitter.com/naveenraj_m), Graduate Student @ University of Alberta**

_This work is an attempt to deploy **knative serving** in k0s with minimum resources. Let's try 1 CPU and 1 GB RAM._

This document has three sections. In first section we capture the resource required by knative serving and k0s. In second section we monitor the actual resource used by Knative and k0s, to determine the size of our k0s (edge) node. Finally, we install knative serving with reduced resource request/limit to k0s node with 1 CPU and 1.5 GB RAM (Why 1.5 GB ? , see  [Knative + k0s resource usage](#knative-k0s-resource-usage) )

If you just want to install knative serving in k0s, you can directly skip to [Knative in k0s ](#knative-in-k0s) Installation section.

* [Resource Requirement Analysis](#resource-requirment-analysis)  
    * [Knative Serving Default Resource Requirement](#knative-serving-default-resource-requirement)
    * [k0s Default Resource Requirement](#k0s-default-resource-requirement)
    * [Knative + k0s Default resource requirement](#knative-k0s-default-resource-requirement)
* [Resource Usage Analysis](#resource-usage-analysis)
    * [Knative resource monitoring](#knative-resource-monitoring)
    * [Knative + k0s resource usage](#knative-k0s-resource-usage)
* [Knative in k0s](#knative-in-k0s)  
    * [Create Edge like Node](#create-edge-like-node)
    * [Install k0s](#install-k0s)
    * [Install Metallb for Load balancing](#install-metallb-for-load-balancing)
    * [Create custom Knative Deployment file](#create-custom-knative-deployment-files)
    * [Install custom Knative deployment files](#install-custom-knative-deployment-files)
    * [Say Hello Edge!](#say-hello-edge)


## Resource Requirment Analysis

In this section we will determine the default Installation resource requirement needed for knative-serving and k0s.

### Knative Serving Default Resource Requirement
knative-serving
```bash
 kubectl get pods  -n knative-serving -o custom-columns="NAME:metadata.name,CPU-REQUEST:spec.containers[*].resources.requests.cpu,CPU-LIMIT:spec.containers[*].resources.limits.cpu,MEM-REQUEST:spec.containers[*].resources.requests.memory,MEM_LIMIT:spec.containers[*].resources.limits.memory"
```

```bash
NAME                                      CPU-REQUEST   CPU-LIMIT   MEM-REQUEST   MEM_LIMIT
activator-7499d967fc-2npcf                300m          1           60Mi          600Mi
autoscaler-568989dd8c-qzrhc               100m          1           100Mi         1000Mi
autoscaler-hpa-854dcfbd44-8vcj8           30m           300m        40Mi          400Mi
controller-76c798ffcb-k96sz               100m          1           100Mi         1000Mi
default-domain-nwbhr                      100m          1           100Mi         1000Mi
net-kourier-controller-79c998474f-svzcm   <none>        <none>      <none>        <none>
webhook-8466d59795-d8zd8                  100m          500m        100Mi         500Mi
```

kourier-system

```bash
kubectl get pods  -n kourier-system -o custom-columns="NAME:metadata.name,CPU-REQUEST:spec.containers[*].resources.requests.cpu,CPU-LIMIT:spec.containers[*].resources.limits.cpu,MEM-REQUEST:spec.containers[*].resources.requests.memory,MEM_LIMIT:spec.containers[*].resources.limits.memory"
```
```bash
NAME                                      CPU-REQUEST   CPU-LIMIT   MEM-REQUEST   MEM_LIMIT
3scale-kourier-gateway-5f9f97b454-rqkgh   <none>        <none>      <none>        <none>
```



**Total**


| **Component**          | **CPU request** | **CPU Limit** | **Memory Request** | **Memory Limit** |
|------------------------|-----------------|---------------|--------------------|------------------|
| activator              | 300m            | 1             | 60Mi               | 600Mi            |
| autoscaler             | 100m            | 1             | 100Mi              | 1000Mi           |
| autoscaler-hpa         | 30m             | 300m          | 40Mi               | 400Mi            |
| controller             | 100m            | 1             | 100Mi              | 1000Mi           |
| default-domain*        | 100m            | 1             | 100Mi              | 1000Mi           |
| net-kourier-controller | \<none\>        | \<none\>      | \<none\>           | \<none\>         |
| webhook                | 100m            | 500m          | 100Mi              | 500Mi            |
| **Total**              | **860m**        | **5600m**     | **640Mi**          | **5400Mi**       |

!!! note
    \*  default-domain is a Job, and the resource will be freed up once the job completes


### k0s Default Resource Requirement

**Resource used by default k0s installation**

Memory Usage
```bash
vagrant@vagrant:~$ free -m
               total        used        free      shared  buff/cache   available
Mem:             971         558          61           0         351         268
Swap:           1941         208        1733
```

Memory used by k0s - 558 m


CPU Usage
```bash
top - 01:55:58 up  2:27,  1 user,  load average: 0.70, 0.42, 0.43
Tasks: 110 total,   1 running, 109 sleeping,   0 stopped,   0 zombie
%Cpu(s):  1.8 us,  0.7 sy,  0.0 ni, 97.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :    971.2 total,     60.9 free,    547.8 used,    362.5 buff/cache
MiB Swap:   1942.0 total,   1734.9 free,    207.1 used.    280.4 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                               
   1222 kube-ap+  20   0 1203728 261064  30408 S   1.7  26.2   4:12.43 kube-apiserver                                                                        
   1213 kube-ap+  20   0  740108  29256   6032 S   1.0   2.9   2:13.01 kine                                                                                  
   1376 kube-ap+  20   0  776892  54388  20112 S   1.0   5.5   1:52.61 kube-controller                                                                       
    602 root      20   0  806420  44088  20408 S   0.7   4.4   0:53.60 k0s                                                                                   
   1283 root      20   0  779664  48132  19672 S   0.7   4.8   2:24.79 kubelet                                                                               
      5 root      20   0       0      0      0 I   0.3   0.0   0:00.29 kworker/0:0-events                                                                    
    347 root      19  -1   56140  14772  14244 S   0.3   1.5   0:04.18 systemd-journal                                                                       
   1282 root      20   0  757300  24652   7024 S   0.3   2.5   0:44.78 containerd                                                                            
   1372 kube-sc+  20   0  765012  24264  13596 S   0.3   2.4   0:16.83 kube-scheduler                                                                        
   1650 root      20   0  757488  14860   8068 S   0.3   1.5   0:03.90 kube-p
```

3% ~ 30m used by k0s ?

**Resource used by BaseOS**

Memory 
```bash
vagrant@vagrant:~$ free -m
               total        used        free      shared  buff/cache   available
Mem:             971         170         502           0         297         668
Swap:           1941           0        1941
```
Memory used by BaseOS 170

CPU
```bash
top - 02:02:20 up 2 min,  1 user,  load average: 0.04, 0.06, 0.02
Tasks:  95 total,   1 running,  94 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.3 us,  0.3 sy,  0.0 ni, 99.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :    971.2 total,    502.7 free,    170.8 used,    297.8 buff/cache
MiB Swap:   1942.0 total,   1942.0 free,      0.0 used.    670.7 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                               
    606 root      20   0  727828  49984  20012 S   1.3   5.0   0:02.68 snapd 
```
CPU used by BaseOS in idle state 0.7%

The results obtained are comporable to experiments by Neil [[1](#resources)]

### Knative + k0s Default resource requirement

Minimum resources needed for VM by the rough estimate 

| **Resource**    | **CPU** | **Memory**       |
|-----------------|----------|------------------|
| k0s             | 30m      | 558 + 208 (swap) |
| knative-serving | 860m     | 640Mi            |
| **Total**       | **890m** | **1406Mi**       |


## Resource Usage Analysis

### Knative resource monitoring

Now , lets create a VM with 2 CPU and 2GB Memory to get knative serving working , so we can capture the metrics of each components. If the resource are not fully utilized we can reduce the minimum requirements of each knative component.

> Creating VM with 1.5 CPU! in vagrant defaults to 1 CPU VM

```bash
# knative core components
vagrant@vagrant:~$ sudo k0s kubectl get pods -n knative-serving
NAME                                      READY   STATUS    RESTARTS   AGE
autoscaler-86796dfc97-2q6b2               1/1     Running   0          19m
controller-7cd4659488-sqz5q               1/1     Running   0          19m
activator-6f78547bf7-xp5jh                1/1     Running   0          19m
webhook-d9c8c747d-fwhst                   1/1     Running   0          19m
net-kourier-controller-54999fc897-st6tn   1/1     Running   0          12m
default-domain-qpvfp                      1/1     Running   0          9m48s

# kourier
vagrant@vagrant:~$ sudo k0s kubectl get pods -n kourier-system
NAME                                     READY   STATUS    RESTARTS   AGE
3scale-kourier-gateway-9b477c667-2hdt2   1/1     Running   0          15m

# 1 knative service
vagrant@vagrant:~$ sudo k0s kubectl get ksvc 
NAME    URL                                      LATESTCREATED   LATESTREADY   READY   REASON
hello   http://hello.default.svc.cluster.local   hello-00001     hello-00001   True  

vagrant@vagrant:~$ sudo k0s kubectl get pods 
NAME                                      READY   STATUS    RESTARTS   AGE
hello-00001-deployment-66ddff5b59-jbn6x   2/2     Running   0          84s
```

Resource Analysis of fully installed knative serving with one knative service, Idle State

```bash
vagrant@vagrant:~$ sudo k0s kubectl top node
NAME      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
vagrant   166m         8%     1341Mi          71%   
```

```bash
vagrant@vagrant:~$ sudo k0s kubectl top pod --all-namespaces
NAMESPACE         NAME                                      CPU(cores)   MEMORY(bytes)   
default           hello-00001-deployment-66ddff5b59-jbn6x   1m           8Mi             
knative-serving   activator-6f78547bf7-xp5jh                2m           21Mi            
knative-serving   autoscaler-86796dfc97-2q6b2               5m           19Mi            
knative-serving   controller-7cd4659488-sqz5q               5m           27Mi            
knative-serving   default-domain-6mknr                      1m           7Mi             
knative-serving   net-kourier-controller-54999fc897-st6tn   6m           37Mi            
knative-serving   webhook-d9c8c747d-fwhst                   9m           16Mi            
kourier-system    3scale-kourier-gateway-9b477c667-2hdt2    4m           17Mi            
kube-system       coredns-7bf57bcbd8-b22j4                  3m           16Mi            
kube-system       kube-proxy-pm4ht                          1m           13Mi            
kube-system       kube-router-vdqtv                         1m           19Mi            
kube-system       metrics-server-7446cc488c-zxdxg           5m           18Mi      
```



### Knative + k0s resource usage

Minimum resources used for VM by the rough estimate 

| **Resource**    | **CPU** | **Memory**       |
|-----------------|----------|------------------|
| k0s + knative-serving | < 160m      | < 1406Mi           |


From this early result, it seems like we might be able to reduce CPU count but ~1.4 GB Memory utilization means that there is little room to reduce memory.

Now lets try reducing resource request and limit by 50% and see if we run into any issue.

## Knative in k0s 

### Create Edge like Node

To do this we will use [vagrant](https://www.vagrantup.com/) VM with 1 CPU and 1.5 GB Memory. 

Vagrantfile
```rb
Vagrant.configure("2") do |config|
    config.vm.define "k0s"
    config.vm.box = "bento/ubuntu-22.04"
    config.vm.provider "virtualbox" do |v|
      v.memory = 1500
      v.cpus = 1
      v.name = "k0s"
    end
end
```

```bash
vagrant up
vagrant ssh k0s
```

### Install k0s

```bash
# Download k0s
curl -sSLf https://get.k0s.sh | sudo sh
# Install k0s as a service
sudo k0s install controller --single
# Start k0s as a service
sudo k0s start
# Check service, logs and k0s status
sudo k0s status
# Access your cluster using kubectl
sudo k0s kubectl get nodes
```

```bash
vagrant@vagrant:~$ sudo k0s kubectl get nodes
E0318 07:24:18.366073    2692 memcache.go:255] couldn't get resource list for metrics.k8s.io/v1beta1: the server is currently unable to handle the request
E0318 07:24:18.381532    2692 memcache.go:106] couldn't get resource list for metrics.k8s.io/v1beta1: the server is currently unable to handle the request
E0318 07:24:18.387961    2692 memcache.go:106] couldn't get resource list for metrics.k8s.io/v1beta1: the server is currently unable to handle the request
E0318 07:24:18.391539    2692 memcache.go:106] couldn't get resource list for metrics.k8s.io/v1beta1: the server is currently unable to handle the request
NAME      STATUS   ROLES           AGE   VERSION
vagrant   Ready    control-plane   61s   v1.26.2+k0s
```

We can already see the effect of running k0s in 1 CPU and 1.5 GB RAM . 

k0s metrics without any additional installs

```bash
vagrant@vagrant:~$ sudo k0s kubectl top node
NAME      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
vagrant   39m          3%     959Mi           71% 
```

### Install Metallb for Load balancing

[Use Metallb native install - for bare metal](https://metallb.universe.tf/installation/)

```bash
sudo k0s kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
```

[Configure IPAdress for LoadBalancer Servcie](https://metallb.universe.tf/configuration/)

Defining The IPs To Assign To The Load Balancer Services.  
ip_pool.yaml
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.10.0/24
```

Announce The Service IPs (Layer 2 Configuration)  
l2_ad.yaml
```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```

Create MatalLB resources
```bash
sudo k0s kubectl apply -f ip_pool.yaml
sudo k0s kubectl apply -f l2_ad.yaml
```


### Create custom knative deployment files

Edit deployment files of all knative serving components by reducing resources to 50% of the original value. 
Ex: if 100m is the orginal value of CPU request/limit , we reduce it to 50m, same is done for memory.

Though reducing by 50% might seem random, when I tried to install the default files , some pods didn't come up due to insufficient CPU. The mimimum request of 890 milli core (see [Knative + k0s Default resource requirement](#knative-k0s-default-resource-requirement)) explains why some pods didn't find  sufficient CPU , since BaseOS + k0s might be using more than 110 m of CPU (1000 - 890)

Hence, after monitoring the resource usage (See [Knative + k0s Resource Usage](#knative-k0s-resource-usage)) and with an aim to fit everything in 1 CPU, reducing the resource request/limit by 50% was a safe option.

You can use the deployment file I have created with reduced resource for next step.

* [serving-crd.yaml](https://gist.github.com/naveenrajm7/865756eaf07631c82dcd42278d02d105)
* [serving-core.yaml](https://gist.github.com/naveenrajm7/6e67e288a3b29b5e7c8b3969d76dca27)
* [kourier.yaml](https://gist.github.com/naveenrajm7/227c4c80a445a373a825f488605d9b1d)
* [serving-default-domain.yaml](https://gist.github.com/naveenrajm7/0b8f36752b0246ac680913580a756ed0)

### Install custom knative deployment files


```bash
# crd.yaml
sudo ks0s kubectl apply -f https://gist.githubusercontent.com/naveenrajm7/865756eaf07631c82dcd42278d02d105/raw/f94b4be95a40b5210ed6647c692235d60cebd83d/serving-crds.yaml
# core
sudo k0s kubectl apply -f https://gist.githubusercontent.com/naveenrajm7/6e67e288a3b29b5e7c8b3969d76dca27/raw/0269701bf5331e2b037ec582bfe09c8818cd8e27/serving-core.yaml
# networking 
sudo k0s kubectl apply -f https://gist.githubusercontent.com/naveenrajm7/227c4c80a445a373a825f488605d9b1d/raw/ddceae84d378fd600c2115ae0e729e03f7e27a76/kourier.yaml

# Check Load balancer
sudo k0s kubectl --namespace kourier-system get service kourier

# before DNS , you should have external IP (via MetalLB)
# dns
sudo k0s kubectl apply -f https://gist.githubusercontent.com/naveenrajm7/0b8f36752b0246ac680913580a756ed0/raw/ffb00218395c7421332b8d251d8b02b05f5a94ad/serving-default-domain.yaml

```


Checking components of knative-serving
```bash
vagrant@vagrant:~$ sudo k0s kubectl get pods -n knative-serving
NAME                                      READY   STATUS      RESTARTS   AGE
autoscaler-84445c7b8f-f8nwq               1/1     Running     0          37m
activator-5f59946cc4-dsx6w                1/1     Running     0          37m
controller-67cc995548-ncvtw               1/1     Running     0          37m
webhook-5c8c986896-f5z8w                  1/1     Running     0          37m
net-kourier-controller-6c89f976bf-4w579   1/1     Running     0          7m25s
default-domain-nghzp                      0/1     Completed   0          17s
```

### Say Hello Edge!
Install customary hello knative service

hello.yaml
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "1"
    spec:
      containers:
        - image: ghcr.io/knative/helloworld-go:latest
          env:
            - name: TARGET
              value: "Edge!!"
```


```bash
# create knative service
vagrant@vagrant:~$ sudo k0s kubectl apply -f hello.yaml
# Check if service is running
vagrant@vagrant:~$ sudo k0s kubectl get ksvc
NAME    URL                                          LATESTCREATED   LATESTREADY   READY   REASON
hello   http://hello.default.192.168.10.0.sslip.io   hello-00001     hello-00001   True    
# Visit service
vagrant@vagrant:~$ curl http://hello.default.192.168.10.0.sslip.io
Hello Edge!!
```

Let's bring knative to edge.

## Resources:

1. Neil Cresswell,
Comparing Resource Consumption in K0s vs K3s vs Microk8s, August 23, 2022 [Blog](https://www.portainer.io/blog/comparing-k0s-k3s-microk8s)

2. [k0s Quick start guide](https://docs.k0sproject.io/v1.23.6+k0s.2/install/)

3. [knative docs](https://knative.dev/)

4. [MetalLB](https://metallb.universe.tf/)
