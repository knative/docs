# Scaling to Zero

**Remember those super powers :rocket: we talked about?** One of Knative Serving's powers is built-in automatic scaling, also known as **autoscaling**.
This means your Knative Service only spins up your application to perform its job (in this case, saying "Hello world!") if it is needed.
Otherwise, it will **scale to zero** by spinning down and waiting for a new request to come in.

??? question "What about scaling up to meet increased demand?"
    Knative Autoscaling also allows you to easily configure your service to scale up
    (horizontal autoscaling) to meet increased demand as well as control the number of instances that
    spin up using
    [concurrency limits and other options](../../serving/autoscaling/concurrency/){target=_blank},
    but that's beyond the scope of this tutorial.

**Let's see this in action!** We're going to peek under the hood at the
[Pod](https://kubernetes.io/docs/concepts/workloads/pods/){target=blank_} in Kubernetes where our
Knative Service is running to watch our "Hello world!" Service scale up and down.

## Watch your Knative Service scale to zero

Let's run our "Hello world!" Service just one more time. This time, try the Knative Service `URL` in
your browser or you can use your terminal with `curl`.
```bash
echo "Accessing URL $(kn service describe hello -o url)"
curl "$(kn service describe hello -o url)"
```

Now watch the pods and see how they scale to zero after traffic stops going to the URL.
```bash
kubectl get pod -l serving.knative.dev/service=hello -w
```

!!! note
    It may take up to 2 minutes for your Pods to scale down. Pinging your service again will reset this timer.


!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME                                     READY   STATUS
    hello-world                              2/2     Running
    hello-world                              2/2     Terminating
    hello-world                              1/2     Terminating
    hello-world                              0/2     Terminating
    ```

## Scale up your Knative Service

Rerun the Knative Service in your browser and you will see a new pod running again.

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME                                     READY   STATUS
    hello-world                              0/2     Pending
    hello-world                              0/2     ContainerCreating
    hello-world                              1/2     Running
    hello-world                              2/2     Running
    ```
Exit the `kubectl watch` command with `Ctrl+c`.

Some people call this **Serverless** :tada: :taco: :fire: Up next, traffic splitting!

??? question "Want to go deeper on Autoscaling?"
    Interested in getting in the weeds with Knative Autoscaling? Check out the [autoscaling documentation](../serving/autoscaling/README.md){target=_blank} for concepts, samples, and more!
