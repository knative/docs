# Configuring Log Settings

Log configuration for all Knative components is managed through the `config-logging` ConfigMap in the corresponding namespace. For example, Serving components are configured through `config-logging` in the `knative-serving` namespace and Eventing components are configured through `config-logging` in the `knative-eventing` namespace, etc.

Knative components use the [zap](https://github.com/uber-go/zap) logging library; options are [documented in more detail in that project](https://github.com/uber-go/zap/blob/master/config.go#L58).

In addition to `zap-logger-config`, which is a general key that applies to all components in that namespace, the `config-logging` ConfigMap supports overriding the log level for individual components.

| ConfigMap key                     | Description                                                                                                                                                      |
| :-------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `zap-logger-config`               | A JSON object container for a zap logger configuration. Key fields are highlighted below.                                                                        |
| `zap-logger-config.level`         | The default logging level for components. Messages at or above this severity level will be logged.                                                               |
| `zap-logger-config.encoding`      | The log encoding format for component logs (defaults to JSON).                                                                                                   |
| `zap-logger-config.encoderConfig` | A `zap` [EncoderConfig](https://github.com/uber-go/zap/blob/10d89a76cc8b9787e408aee8882e40a8bd29c585/zapcore/encoder.go#L312) used to customize record contents. |
| `loglevel.<component>`            | Overrides logging level for the given component only. Messages at or above this severity level will be logged.                                                   |

Log levels supported by Zap are:

- `debug` - fine-grained debugging
- `info` - normal logging
- `warn` - unexpected but non-critical errors
- `error` - critical errors; unexpected during normal operation
- `dpanic` - in debug mode, trigger a panic (crash)
- `panic` - trigger a panic (crash)
- `fatal` - immediately exit with exit status 1 (failure)
