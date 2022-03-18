# Hello World - Python

A simple web app written in Python that you can use to test knative eventing. It shows how to consume a [CloudEvent](https://cloudevents.io/) in Knative eventing, and optionally how to respond back with another CloudEvent in the http response, by adding the Cloud Eventing headers outlined in the Cloud Events standard definition.

We will deploy the app as a [Kubernetes Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) along with a [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/).
However, you can also deploy the app as a [Knative Serving Service](https://knative.dev/docs/serving/).

Do the following steps to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```bash
# Clone the relevant branch version such as "release-0.13"
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/eventing/helloworld/helloworld-python
```

## Before you begin

- A Kubernetes cluster with [Knative Eventing](https://knative.dev/docs/install/eventing/install-eventing-with-yaml) installed.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new file named `helloworld.py` and paste the following code. This
   code creates a basic web server which listens on port 8080:

    ```python
    from flask import Flask, request, make_response
    import uuid

    app = Flask(__name__)

    @app.route('/', methods=['POST'])
    def hello_world():
        app.logger.warning(request.data)
        # Respond with another event (optional)
        response = make_response({
            "msg": "Hi from helloworld-python app!"
        })
        response.headers["Ce-Id"] = str(uuid.uuid4())
        response.headers["Ce-specversion"] = "0.3"
        response.headers["Ce-Source"] = "knative/eventing/samples/hello-world"
        response.headers["Ce-Type"] = "dev.knative.samples.hifromknative"
        return response

    if __name__ == '__main__':
        app.run(debug=True, host='0.0.0.0', port=8080)
    ```

1. Add a `requirements.txt` file containing the following contents:

    ```bash
    Flask==2.0.3
    ```

1. In your project directory, create a file named `Dockerfile` and copy the following code
   block into it. For detailed instructions on dockerizing a Go app, see
   [Deploying Go servers with Docker](https://blog.golang.org/docker).

    ```docker
    FROM python:3.9-alpine

    COPY . /app

    WORKDIR /app

    RUN pip install -r requirements.txt

    EXPOSE 8080

    ENTRYPOINT [ "python" ]

    CMD [ "helloworld.py" ]

    ```

1. Create a new file, `sample-app.yaml` and copy the following service definition into the file. Make sure to replace `{username}` with your Docker Hub username.

    ```yaml
    # Namespace for sample application with eventing enabled
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-samples
      labels:
           eventing.knative.dev/injection: enabled
    ---
    # A default broker
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      name: default
      namespace: knative-samples
      annotations:
        # Note: you can set the eventing.knative.dev/broker.class annotation to change the class of the broker.
        # The default broker class is MTChannelBasedBroker, but Knative also supports use of the other class.
        eventing.knative.dev/broker.class: MTChannelBasedBroker
    spec: {}
    ---
    # Helloworld-python app deployment
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: helloworld-python
      namespace: knative-samples
    spec:
      replicas: 1
      selector:
        matchLabels: &labels
          app: helloworld-python
      template:
        metadata:
          labels: *labels
        spec:
          containers:
            - name: helloworld-python
              image: docker.io/{username}/helloworld-python
              imagePullPolicy: IfNotPresent
    ---
    # Service that exposes helloworld-python app.
    # This will be the subscriber for the Trigger
    apiVersion: v1
    kind: Service
    metadata:
      name: helloworld-python
      namespace: knative-samples
    spec:
      selector:
        app: helloworld-python
      ports:
      - protocol: TCP
        port: 80
        targetPort: 8080
    ---
    # Knative Eventing Trigger to trigger the helloworld-python service
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: helloworld-python
      namespace: knative-samples
    spec:
      broker: default
      filter:
        attributes:
          type: dev.knative.samples.helloworld
          source: dev.knative.samples/helloworldsource
      subscriber:
        ref:
          apiVersion: v1
          kind: Service
          name: helloworld-python
    ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with Docker Hub, run these commands replacing `{username}` with your Docker Hub username:

    ```bash
    # Build the container on your local machine
    docker build -t {username}/helloworld-python .
    # Push the container to docker registry
    docker push {username}/helloworld-python
    ```

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the sample application into your cluster. Ensure that the container image value in `sample-app.yaml` matches the container you built in the previous step. Apply the configuration using `kubectl`:

    ```bash
    kubectl apply -f sample-app.yaml
    ```

1. The previous command creates a namespace `knative-samples` and labels it with `knative-eventing-injection=enabled`, to enable eventing in the namespace. Verify using the following command:

    ```bash
    kubectl get ns knative-samples --show-labels
    ```

1. It deployed the `helloworld-python` app as a K8s Deployment and created a K8s service names helloworld-python. Verify using the following command:

    ```bash
    kubectl --namespace knative-samples get deployments helloworld-python
    kubectl --namespace knative-samples get svc helloworld-python
    ```

1. It created a Knative Eventing Trigger to route certain events to the helloworld-python application. Make sure that `Ready=true`:

    ```bash
    kubectl -n knative-samples get trigger helloworld-python
    ```

## Send and verify CloudEvents

After you have deployed the application, and have verified that the namespace, sample application and trigger are ready, you can send a CloudEvent.

### Send CloudEvent to the Broker

You can send an HTTP request directly to the Knative [Broker](https://knative.dev/docs/eventing/broker/) if the correct CloudEvent headers are set.

1. Deploy a curl pod and SSH into it:

    ```bash
    kubectl --namespace knative-samples run curl --image=radial/busyboxplus:curl -it
    ```

1. Run the following command in the SSH terminal:

    ```bash
    curl -v "broker-ingress.knative-eventing.svc.cluster.local/knative-samples/default" \
    -X POST \
    -H "Ce-Id: 536808d3-88be-4077-9d7a-a3f162705f79" \
    -H "Ce-specversion: 0.3" \
    -H "Ce-Type: dev.knative.samples.helloworld" \
    -H "Ce-Source: dev.knative.samples/helloworldsource" \
    -H "Content-Type: application/json" \
    -d '{"msg":"Hello World from the curl pod."}'
    exit
    ```

### Verify that event is received by helloworld-python app

The Helloworld-python app logs the context and the msg of the event you created earlier, and replies with another event.

  1. Display helloworld-python app logs
      ```bash
      kubectl --namespace knative-samples logs -l app=helloworld-python --tail=50
      ```
      You should see something similar to:
      ```{ .bash .no-copy }
      Event received. Context: Context Attributes,
        specversion: 0.3
        type: dev.knative.samples.helloworld
        source: dev.knative.samples/helloworldsource
        id: 536808d3-88be-4077-9d7a-a3f162705f79
        time: 2019-10-04T22:35:26.05871736Z
        datacontenttype: application/json
      Extensions,
        knativearrivaltime: 2019-10-04T22:35:26Z
        knativehistory: default-kn2-trigger-kn-channel.knative-samples.svc.cluster.local
        traceparent: 00-971d4644229653483d38c46e92a959c7-92c66312e4bb39be-00

      Hello World Message "Hello World from the curl pod."
      Responded with event Validation: valid
      Context Attributes,
        specversion: 0.2
        type: dev.knative.samples.hifromknative
        source: knative/eventing/samples/hello-world
        id: 37458d77-01f5-411e-a243-a459bbf79682
      Data,
        {"msg":"Hi from Knative!"}

      ```
  Try the CloudEvent attributes in the curl command and the trigger specification to understand how
  [Triggers](https://knative.dev/docs/eventing/broker/triggers/) work.

## Verify reply from helloworld-python app
The `helloworld-python` app replies with an event type `type= dev.knative.samples.hifromknative`, and source `source=knative/eventing/samples/hello-world`. The event enters the eventing mesh through the broker, and can be delivered to event sinks using a trigger

1. Deploy a Pod that receives any CloudEvent and logs the event to its output.

    1. Copy the following YAML into a file:

        ```yaml
        # event-display app deploment
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: event-display
          namespace: knative-samples
        spec:
          replicas: 1
          selector:
            matchLabels: &labels
              app: event-display
          template:
            metadata:
              labels: *labels
            spec:
              containers:
                - name: helloworld-python
                  image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
        ---
        # Service that exposes event-display app.
        # This will be the subscriber for the Trigger
        kind: Service
        apiVersion: v1
        metadata:
          name: event-display
          namespace: knative-samples
        spec:
          selector:
            app: event-display
          ports:
            - protocol: TCP
              port: 80
              targetPort: 8080
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. Create a trigger to deliver the event to the previously created service.

    1. Copy the following YAML into a file:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Trigger
        metadata:
          name: event-display
          namespace: knative-samples
        spec:
          broker: default
          filter:
            attributes:
              type: dev.knative.samples.hifromknative
              source: knative/eventing/samples/hello-world
          subscriber:
            ref:
              apiVersion: v1
              kind: Service
              name: event-display
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

1. [Send a CloudEvent to the Broker](#send-and-verify-cloudevents)

1. Check the logs of `event-display` Service:

    ```bash
    kubectl -n knative-samples logs -l app=event-display --tail=50
    ```

    Example output:

    ```{ .bash .no-copy }
        cloudevents.Event
        Validation: valid
        Context Attributes,
          specversion: 0.3
          type: dev.knative.samples.hifromknative
          source: knative/eventing/samples/hello-world
          id: 8a7384b9-8bbe-4634-bf0f-ead07e450b2a
          time: 2019-10-04T22:53:39.844943931Z
          datacontenttype: application/json
        Extensions,
          knativearrivaltime: 2019-10-04T22:53:39Z
          knativehistory: default-kn2-ingress-kn-channel.knative-samples.svc.cluster.local
          traceparent: 00-4b01db030b9ea04bb150b77c8fa86509-2740816590a7604f-00
        Data,
          {
            "msg": "Hi from helloworld- app!"
          }
    ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete -f sample-app.yaml
```
