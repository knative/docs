# Autoscaling

Knative Serving provides automatic scaling, also known as **autoscaling**. This means that a Knative Service by default scales down to zero running pods when it is not in use.

## List your Knative Service

Use the Knative (`kn`) CLI to view the URL where your Knative Service is hosted:

=== "kn"
    View a list of Knative Services by running the command:
    ```bash
    kn service list
    ```
    !!! Success "Expected output"
        ```bash
        NAME    URL                                                LATEST        AGE   CONDITIONS   READY
        hello   http://hello.default.${LOADBALANCER_IP}.sslip.io   hello-00001   13s   3 OK / 3     True
        ```
=== "kubectl"
    View a list of Knative Services by running the command:
    ```bash
    kubectl get ksvc
    ```
    !!! Success "Expected output"
        ```bash
        NAME    URL                                                LATESTCREATED   LATESTREADY   READY   REASON
        hello   http://hello.default.${LOADBALANCER_IP}.sslip.io   hello-00001     hello-00001   True
        ```

## Access your Knative Service

Access your Knative Service by opening the previous URL in your browser or by running the command:

```bash
echo "Accessing URL $(kn service describe hello -o url)"
curl "$(kn service describe hello -o url)"
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Hello World!
    ```

??? question "Are you seeing `curl: (6) Could not resolve host: hello.default.${LOADBALANCER_IP}.sslip.io`?"

    In some cases your DNS server may be set up not to resolve `*.sslip.io` addresses. If you encounter this problem, it can be fixed by using a different nameserver to resolve these addresses.

    The exact steps will differ according to your distribution. For example, with Ubuntu derived systems which use `systemd-resolved`, you can add the following entry to the `/etc/systemd/resolved.conf`:

    ```ini
    [Resolve]
    DNS=8.8.8.8
    Domains=~sslip.io.
    ```

    Then simply restart the service with `sudo service systemd-resolved restart`.

    For MacOS users, you can add the DNS and domain using the network settings as explained [here](https://support.apple.com/en-gb/guide/mac-help/mh14127/mac).

## Observe autoscaling

Watch the pods and see how they scale to zero after traffic stops going to the URL:

```bash
kubectl get pod -l serving.knative.dev/service=hello -w
```

!!! note
    It may take up to 2 minutes for your pods to scale down. Pinging your service again resets this timer.

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME                                     READY   STATUS
    hello-world                              2/2     Running
    hello-world                              2/2     Terminating
    hello-world                              1/2     Terminating
    hello-world                              0/2     Terminating
    ```

## Scale up your Knative Service

Rerun the Knative Service in your browser. You can see a new pod running again:

!!! Success "Expected output"
    ```{ .bash .no-copy }
    NAME                                     READY   STATUS
    hello-world                              0/2     Pending
    hello-world                              0/2     ContainerCreating
    hello-world                              1/2     Running
    hello-world                              2/2     Running
    ```

Exit the `kubectl watch` command with `Ctrl+c`.
