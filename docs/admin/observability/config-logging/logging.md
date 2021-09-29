# Configuring Log Settings

Log configuration for all Knative components is managed via the `config-logging` ConfigMap in the corresponding namespace. (Serving components are configured via `config-logging` in `knative-serving` namespace, Eventing components via `config-logging` in `knative-eventing` namespace, etc.)

Knative components use the [zap](https://github.com/uber-go/zap) logging library; options are [documented in more detail in that project](https://github.com/uber-go/zap/blob/master/config.go#L58).

In addition to a general key `zap-logger-config` which applies to all components in that namespace, the `config-logging` ConfigMap supports overriding the log level for individual components.

| ConfigMap key                     | Description                                                                                                                                                      |
| :-------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `zap-logger-config`               | A JSON object container a zap logger configuration. Key fields are highlighted below.                                                                            |
| `zap-logger-config.level`         | The default logging level for components. Messages at or above this severity level will be logged.                                                               |
| `zap-logger-config.encoding`      | The log encoding format for component logs (defaults to JSON).                                                                                                   |
| `zap-logger-config.encoderConfig` | A `zap` [EncoderConfig](https://github.com/uber-go/zap/blob/10d89a76cc8b9787e408aee8882e40a8bd29c585/zapcore/encoder.go#L312) used to customize record contents. |
| `loglevel.<component>`            | Override logging level for the given component only. Messages at or above this severity level will be logged.                                                    |

Log levels supported by Zap are:

- debug - fine-grained debugging
- info - normal logging
- warn - unexpected but non-critical errors
- error - critical errors; unexpected during normal operation
- dpanic - in debug mode, trigger a panic (crash)
- panic - trigger a panic (crash)
- fatal - immediately exit with exit status 1 (failure)
