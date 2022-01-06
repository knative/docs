# Configuring a custom certificate class for a Service

When autoTLS is enabled and Knative Services are created, a certificate class (`certificate-class`) is automatically chosen based on the value in the `config-network` ConfigMap located inside the `knative-serving` namespace. This ConfigMap is part of Knative Serving installation. If the certificate class is not specified, this defaults to `cert-manager.certificate.networking.knative.dev`. After `certificate-class` is configured, it is used for all Knative Services unless it is overridden with a `certificate-class` annotation.

## Using the certificate class annotation

Generally it is recommended for Knative Services to use the default `certificate-class`. However, in scenarios where there are multiple certificate providers, you might want to specify different certificate class annotations for each Service.

You can configure each Service to use a different certificate class by specifying the `networking.knative.dev/certificate-class` annotation.

To add a certificate class annotation to a Service, run the following command:
```bash
kubectl annotate kservice <service-name> networking.knative.dev/certifcate-class=<certificate-provider>
```
Where:

- `<service-name>` is the name of the Service that you are applying the annotation to.
- `<certificate-provider>` is the type of certificate provider that is used as the certificate class for the Service.

