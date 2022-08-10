## Create a Service

1. Create the `event-display` Service as a YAML file:

     ```yaml
     apiVersion: serving.knative.dev/v1
     kind: Service
     metadata:
       name: event-display
       namespace: default
     spec:
       template:
         spec:
           containers:
             - # This corresponds to
               # https://github.com/knative/eventing/tree/main/cmd/event_display/main.go
               image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
     ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

    Example output:
    ```{ .bash .no-copy }
    service.serving.knative.dev/event-display created
    ```

1. Ensure that the Service Pod is running, by running the command:

    ```bash
    kubectl get pods
    ```

    The Pod name is prefixed with `event-display`:
    ```{ .bash .no-copy }
    NAME                                            READY     STATUS    RESTARTS   AGE
    event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
    ```
