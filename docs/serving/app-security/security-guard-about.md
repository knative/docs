# About Security-Guard

Guard provides visibility into the security status of deployed Knative Services, by monitoring the behaviors of user containers and events. It creates a profile of these behaviors, which are compared to a pre-defined criteria. If the profile does not meet the criteria, Guard can log alerts, block events, or stop the Service, depending on user configurations.

The criteria that a profile is compared to is composed of a set of micro-rules. These rules describe expected behaviors for events and user containers, including expected responses. You can choose to set micro-rules manually, or use Guard's machine learning feature to automate the creation of micro-rules. A per-Service set of micro-rules is stored in the Kubernetes system as a `Guardian` object.

## Security-Guard Use Cases

### Normal Services

Under normal conditions, the Knative user who owns the service is not aware of any known vulnerabilities in the service. Yet, it is reasonable to assume that the service has weaknesses. Security-Guard offers Knative users the ability to detect/block patterns sent as part of incoming events that may be used to exploit unknown, zero-day, service vulnerabilities.

### Vulnerable Services

Once a CVE that describes a vulnerability in the service is published, the Knative user who owns the service is required to start a process to eliminate the vulnerability by introducing a new revision of the service. This process of removing a known vulnerability may take many weeks to accomplish. Knative users need to continue offering services, although the service has a known vulnerability, and therefore need to detect/block incoming events that include patterns that may be used to exploit the discovered vulnerability.

### Exploitable Services

When a known exploit is found effective to compromise a service, the Knative user who owns the Service needs a way to filter incoming events that contain the exploit. This is normally the case during a successful attack, where a working exploit is able to compromise the user-container. Users therefore need a way to detect/block incoming events that include the exploit while allowing other events to be served.

### Misused Services

Users need a way to detect/remove misused Service instances while allowing other instances to continue serve events - i.e. the user needs a way to stop Service instances that are exploited and are being misused.

## More information

See Readme files in the [Security-Guard Github Repository](http://knative.dev/security-guard).
