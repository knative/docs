# About Security-Guard

Security-Guard provides visibility into the security status of deployed Knative Services, by monitoring the behaviors of user containers and events.

## Security-Guard profile and criteria

Security-Guard creates a profile of the user container behavior and of event behavior.
The behaviors are then compared to a pre-defined criteria.
If the profile does not meet the criteria, Security-Guard can log alerts, block events, or stop a Service instance, depending on user configurations.

The criteria that a profile is compared to is composed of a set of micro-rules. These rules describe expected behaviors for events and user containers, including expected responses. You can choose to set micro-rules manually, or use Security-Guard's machine learning feature to automate the creation of micro-rules.

## Guardians

A per-Service set of micro-rules is stored in the Kubernetes system as a `Guardian` object. Under Knative, Security-Guard store Guardians ny default using the `guardians.guard.security.knative.dev` CRDs.

To list all CRD Guardians use:

```bash
kubectl get guardians.guard.security.knative.dev
```

Example Output:

```sh
NAME            AGE
helloworld-go   10h
```

## Security-Guard Use Cases

Security-Guard support four different stages in the life of a knative service from a security standpoint.

* Zero-Day
* Vulnerable
* Exploitable
* Misused

We next detail each stage and how Security-Guard is used to manage the security of the service in that stage.

### Zero-Day

Under normal conditions, the Knative user who owns the service is not aware of any known vulnerabilities in the service. Yet, it is reasonable to assume that the service has weaknesses.

Security-Guard offers Knative users the ability to detect/block patterns sent as part of incoming events that may be used to exploit unknown, zero-day, service vulnerabilities.

### Vulnerable

Once a CVE that describes a vulnerability in the service is published, the Knative user who owns the service is required to start a process to eliminate the vulnerability by introducing a new revision of the service. This process of removing a known vulnerability may take many weeks to accomplish.

Security-Guard enables Knative users to set micro-rules to detect/block incoming events that include patterns that may be used as part of some future exploit targeting the discovered vulnerability. In this way, users are able to continue offering services, although the service has a known vulnerability.

### Exploitable

When a known exploit is found effective in compromising a service, the Knative user who owns the Service needs a way to filter incoming events that contain the specific exploit. This is normally the case during a successful attack, where a working exploit is able to compromise the user-container.

Security-Guard enables Knative users a way to set micro-rules to detect/block incoming events that include specific exploits while allowing other events to be served.

### Misused

When an offender has established an attack pattern that is able to take over a service instance, by first exploiting one or more vulnerabilities and then starting to misuse the service instance, stopping the service instance requires the offender to repeat the attack pattern. At any given time, some service instances may be compromised and misused while others behave as designed.

Security-Guard enables Knative user a way to detect/remove misused Service instances while allowing other instances to continue serve events.

## Additional resources

See Readme files in the [Security-Guard Github Repository](http://knative.dev/security-guard).
