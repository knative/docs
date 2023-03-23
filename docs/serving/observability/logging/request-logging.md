# Configuring Request Log Settings

The request logging for knative serving is managed through the `config-observability` ConfigMap in `knative-serving` namespace. The request logs will be printed by the queue-proxy sidecar.

Mentioned below are the flags used to configure request logging features.


| ConfigMap key                     | Description                                                                                                                                                      |
| :-------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `logging.enable-request-log` | If true, the request logging will be enabled. |
| `logging.enable-probe-request-log`            | If true, this enables queue proxy writing request logs for probe requests to stdout. It uses the same template as user requests, i.e. ```logging.request-log-template```.  |
| `logging.request-log-template`      | The value determines the shape of the request logs and it must be a valid go text/template. It is important to keep this as a single line. Multiple lines are parsed as separate entities by most collection agents and will split the request logs into multiple records.  |





