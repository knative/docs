# Demo Knative autoscaling

 I this demo we will use our original `simple-app` we deployed at the beginning of the demo.

 ## n to 0

 First, let's check on the app we deployed

```shell
watch kubectl get pods
```

 As you can see the `simple-app` pod is not there. It's because it has scaled down.

 ## 0 to 1

 Now, let's bring this app back up but simply simulating user and access its URL

http://simple.default.project-serverless.com/

And monitor the pods again

```shell
watch kubectl get pods
```

Now we can see the `simple-*` pod span up and ready to serve

## 1 to n

Now, let's use synthetic load generator to quickly increase the number of Queries Per Second (QPS) to demonstrate how Knative sales its workloads.

```shell
auto-scaling/stress-test.sh
```

We gonna use our script to spin up 4 threads running more than 1K QPS each to see how Knative scales the underlining pod

```shell
watch kubectl get pods
```
