---
audience: developer
components:
  - eventing
function: how-to
---

# JobSink, triggering long-running background jobs when events occurs

Usually event processing combined with a Knative Service is expected to complete in a relative short
period of time (minutes) as it requires the HTTP connection to stay open as otherwise the service is
scaled down.

Keeping long-running connections open increases the possibility of failing and so
the processing needs to restart as the request is retried.

This limitation is not ideal, `JobSink` is a resource you can use to create long-running
asynchronous jobs and tasks.

`JobSink` supports the full
Kubernetes [batch/v1 Job resource and features](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
and Kubernetes Job queuing systems like [Kueue](https://kueue.sigs.k8s.io/).

## Prerequisites

You must have access to a Kubernetes cluster
with [Knative Eventing installed](../../install/yaml-install/eventing/install-eventing-with-yaml.md).

## Usage

When an event is sent to a `JobSink`, Eventing creates a `Job` and mounts the received event as
JSON file at `/etc/jobsink-event/event`.

1. Create a `JobSink`
    ```yaml
    apiVersion: sinks.knative.dev/v1alpha1
    kind: JobSink
    metadata:
      name: job-sink-logger
    spec:
      job:
        spec:
          completions: 1
          parallelism: 1
          template:
            spec:
              restartPolicy: Never
              containers:
                - name: main
                  image: docker.io/library/bash:5
                  command: [ "cat" ]
                  args:
                    - "/etc/jobsink-event/event"
    ```
2. Apply the `JobSink` resource:
    ```shell
    kubectl apply -f <job-sink-file.yaml>
    ```
3. Verify `JobSink` is ready:
    ```shell
    kubectl get jobsinks.sinks.knative.dev
    ```
   Example output:
    ```shell
    NAME              URL                                                                          AGE   READY   REASON
    job-sink-logger   http://job-sink.knative-eventing.svc.cluster.local/default/job-sink-logger   5s    True
    ```
4. Trigger a `JobSink`
   ```shell
   kubectl run curl --image=curlimages/curl --rm=true --restart=Never -ti -- -X POST -v \
      -H "content-type: application/json"  \
      -H "ce-specversion: 1.0" \
      -H "ce-source: my/curl/command" \
      -H "ce-type: my.demo.event" \
      -H "ce-id: 123" \
      -d '{"details":"JobSinkDemo"}' \
      http://job-sink.knative-eventing.svc.cluster.local/default/job-sink-logger
   ```
5. Verify a `Job` is created and prints the event:
   ```shell
   kubectl logs job-sink-loggerszoi6-dqbtq
   ```
   Example output:
    ```shell
    {"specversion":"1.0","id":"123","source":"my/curl/command","type":"my.demo.event","datacontenttype":"application/json","data":{"details":"JobSinkDemo"}}
    ```

### JobSink idempotency

`JobSink` will create a job for each _different_ received event.

An event is uniquely identified by the combination of event `source` and `id` attributes.

If an event with the same `source` and `id` attributes is received and a job is already present,
another `Job` will _not_ be created.

### Reading the event file

You can read the file and deserialize it using any [CloudEvents](https://github.com/cloudevents)
JSON deserializer.

For example, the following snippet reads an event using the CloudEvents Go SDK and processes it.

```go
package mytask

import (
	"encoding/json"
	"fmt"
	"os"

	cloudevents "github.com/cloudevents/sdk-go/v2"
)

func handleEvent() error {
	eventBytes, err := os.ReadFile("/etc/jobsink-event/event")
	if err != nil {
		return err
	}

	event := &cloudevents.Event{}
	if err := json.Unmarshal(eventBytes, event); err != nil {
		return err
	}

	// Process event ...
	fmt.Println(event)

	return nil
}
```

### Trigger a Job from different event sources

A `JobSink` can be triggered by any [event source](./../sources) or [trigger](./../triggers).

For example, you can trigger a `Job` when a Kafka record is sent to a Kafka topic using
a [`KafkaSource`](./../sources/kafka-source):

```yaml
apiVersion: sources.knative.dev/v1
kind: KafkaSource
metadata:
  name: kafka-source
spec:
  bootstrapServers:
    - my-cluster-kafka-bootstrap.kafka:9092
  topics:
    - knative-demo-topic
  sink:
    ref:
      apiVersion: sinks.knative.dev/v1alpha1
      kind: JobSink
      name: job-sink-logger
```

or when Knative Broker receives an event using a [`Trigger`](./../triggers):

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-job-sink-trigger
spec:
  broker: my-broker
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
    subscriber:
      ref:
        apiVersion: sinks.knative.dev/v1alpha1
        kind: JobSink
        name: job-sink-logger
```

or even as dead letter sink for a Knative Broker

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: my-broker
spec:
  # ...

  delivery:
    deadLetterSink:
      ref:
        apiVersion: sinks.knative.dev/v1alpha1
        kind: JobSink
        name: job-sink-logger
    retry: 5
    backoffPolicy: exponential
    backoffDelay: "PT1S"
```

### Customizing the event file directory

```yaml
apiVersion: sinks.knative.dev/v1alpha1
kind: JobSink
metadata:
  name: job-sink-custom-mount-path
spec:
  job:
    spec:
      completions: 1
      parallelism: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: main
              image: docker.io/library/bash:5
              command: [ "bash" ]
              args:
                - -c
                - echo "Hello world!" && sleep 5

              # The event will be available in a file at `/etc/custom-path/event`
              volumeMounts:
                - name: "jobsink-event"
                  mountPath: "/etc/custom-path"
                  readOnly: true

```

### Cleaning up finished jobs

To clean up finished jobs, you can set
the [`spec.job.spec.ttlSecondsAfterFinished: 600` field](https://kubernetes.io/docs/concepts/workloads/controllers/job/#clean-up-finished-jobs-automatically)
and Kubernetes will remove finished jobs after 600 seconds (10 minutes).

## JobSink examples

### JobSink success example

```yaml
apiVersion: sinks.knative.dev/v1alpha1
kind: JobSink
metadata:
  name: job-sink-success
spec:
  job:
    metadata:
      labels:
        my-label: my-value
    spec:
      completions: 12
      parallelism: 3
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: main
              image: docker.io/library/bash:5
              command: [ "bash" ]
              args:
                - -c
                - echo "Hello world!" && sleep 5
      backoffLimit: 6
      podFailurePolicy:
        rules:
          - action: FailJob
            onExitCodes:
              containerName: main      # optional
              operator: In             # one of: In, NotIn
              values: [ 42 ]
          - action: Ignore             # one of: Ignore, FailJob, Count
            onPodConditions:
              - type: DisruptionTarget   # indicates Pod disruption
```

### JobSink failure example

```yaml
apiVersion: sinks.knative.dev/v1alpha1
kind: JobSink
metadata:
  name: job-sink-failure
spec:
  job:
    metadata:
      labels:
        my-label: my-value
    spec:
      completions: 12
      parallelism: 3
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: main
              image: docker.io/library/bash:5
              command: [ "bash" ]        # example command simulating a bug which triggers the FailJob action
              args:
                - -c
                - echo "Hello world!" && sleep 5 && exit 42
      backoffLimit: 6
      podFailurePolicy:
        rules:
          - action: FailJob
            onExitCodes:
              containerName: main      # optional
              operator: In             # one of: In, NotIn
              values: [ 42 ]
          - action: Ignore             # one of: Ignore, FailJob, Count
            onPodConditions:
              - type: DisruptionTarget   # indicates Pod disruption
```

