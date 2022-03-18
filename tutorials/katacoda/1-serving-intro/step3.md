## Scaling to Zero

**Remember those super powers 🚀 we talked about?** One of Knative Serving's powers is built-in automatic scaling (autoscaling). 
This means your Knative Service only spins up your application to perform its job -- in this case, saying "Hello world!" 
-- if it is needed; otherwise, it will "scale to zero" by spinning down and waiting for a new request to come in.

> **What about scaling up to meet increased demand?**
> Knative Autoscaling also allows you to easily configure your service to scale up (horizontal autoscaling) to meet 
> increased demand as well as control the number of instances that spin up using 
> [concurrency limits and other options](https://knative.dev/docs/serving/autoscaling/concurrency/), 
> but that's beyond the scope of this tutorial.


**Let's see this in action!** We're going to peek under the hood at the [Pod](https://kubernetes.io/docs/concepts/workloads/pods/)
in Kubernetes where our Knative Service is 
running to watch our "Hello world!" Service scale up and down.

### Run your Knative Service
Let's run our "Hello world!" Service just one more time. Use your terminal with curl.
```sh
curl -H "Host: hello.default.example.com" $externalIP
```{{execute T1}}

You can watch the pods and see how they scale to zero after traffic stops going to the URL (opened in a new Terminal tab,
if the command does not run automatically, click the command bellow again)
`kubectl get pod -l serving.knative.dev/service=hello -w`{{execute T2}}

> **Warning**
> It may take up to 2 minutes for your Pods to scale down. Pinging your service again will reset this timer.

**Expected output:**
```sh
NAME                                     READY   STATUS
hello-world                              2/2     Running
hello-world                              2/2     Terminating
hello-world                              1/2     Terminating
hello-world                              0/2     Terminating
```

### Scale up your Knative Service
Rerun the Knative Service in your terminal and you will see a new pod running again.
`curl -H "Host: hello.default.example.com" $externalIP`{{execute T1}}

Go back to the `Terminal 2` tab, and you can watch the pods and see how they scale up again

**Expected output:**
```sh
NAME                                     READY   STATUS
hello-world                              0/2     Pending
hello-world                              0/2     ContainerCreating
hello-world                              1/2     Running
hello-world                              2/2     Running
```

Exit the watch command with
`^C`{{execute ctrl-seq}}

Some people call this **Serverless** 🎉 🌮 🔥 Up next, traffic splitting!

> **Want to go deeper on Autoscaling?**
> Interested in getting in the weeds with Knative Autoscaling? Check out the 
> [autoscaling documentation](https://knative.dev/docs/serving/autoscaling/) for concepts, 
> samples, and more!