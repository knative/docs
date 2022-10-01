# About Security-Guard

Security-Guard is a Knative instrumentation to monitor the security-behavior of user-containers and of Knative events in order to provide visibility into the security of deployed services. The instrumentation profile the behavior of received events and the behavior of the user-container processing them. The profiles are compared to a pre-defined  criteria. If the profile does not meet the criteria, Security-Guard may log an alert, may block the event or stop the service instance - all as defined by the knative user.

The criteria is composed of a set of micro-rules describing the expectations from events and from the pod response and its general behavior. Knative users may choose to set micro-rules manually or may choose to use the Security-Guard offered machine learning feature to automate the creation of micro-rules. A per service set of micro-rules is stored in the Kubernetes system as a Guardian object - See diagram below. The Security-Guard supports storing the Guardian as a ConfigMap or as a CRD.

## Security-Guard Use Cases

### Normal Services

Under normal conditions, the Knative user who owns the service is not aware of any known vulnerabilities in the service. Yet, it is reasonable to assumed that the service has weaknesses. Security-Guard offers Knative users the ability to detect/block patterns sent as part of incoming events that may be used to exploit unknown, zero-day, service vulnerabilities.

### Vulnerable Services

Once a CVE that describes a vulnerability in the service is published, the Knative user who owns the service is required to start a process to eliminate the vulnerability by introducing a new revision of the service. This process of removing a known vulnerability may take many weeks to accomplish. Knative users need to continue offering services, although the service has a known vulnerability, and therefore need to detect/block incoming events that include patterns that may be used to exploit the discovered vulnerability.

### Exploitable Services

When a known exploit is found effective to compromise a service, the Knative user who owns the service need a way to filter incoming events that contain the exploit. This is normally the case during a successful attack, where a working exploit is able to compromise the user-container. Users therefore need a way to detect/block incoming events that include the exploit while allowing other events to be served.

### Misused Services

Users need a way to detect/remove misused service instances while allowing other instances to continue the service - i.e. the user need a way to stop service instances that ware exploited and are being misused.

## More information

See a [Security-Guard Monitoring Quickstart](./security-guard-quickstart.md).

See Readme files in the [Security-Guard Github Repository](http://knative.dev/security-guard).
