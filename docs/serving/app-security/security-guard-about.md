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

    ```
    kubectl get guardians.guard.security.knative.dev 
    ```

Example Output:

    ```
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

Under normal conditions, the Knative user who owns the service is not aware of any known vulnerabilities in the service. Yet, it is reasonable to assume that the service has weaknesses. Security-Guard offers Knative users the ability to detect/block patterns sent as part of incoming events that may be used to exploit unknown, zero-day, service vulnerabilities.

### Vulnerable

Once a CVE that describes a vulnerability in the service is published, the Knative user who owns the service is required to start a process to eliminate the vulnerability by introducing a new revision of the service. This process of removing a known vulnerability may take many weeks to accomplish. Knative users need to continue offering services, although the service has a known vulnerability, and therefore need to detect/block incoming events that include patterns that may be used as part of some future exploit targeting the discovered vulnerability.

### Exploitable

When a known exploit is found effective to compromise a known vulnerability included in the service, the Knative user who owns the Service needs a way to filter incoming events that contain the specific exploit. This is normally the case during a successful attack, where a working exploit is able to compromise the user-container. Users therefore need a way to detect/block incoming events that include specific exploits while allowing other events to be served.

### Misused

Users need a way to detect/remove misused Service instances while allowing other instances to continue serve events - i.e. the user needs a way to stop Service instances that are exploited and are being misused.

## Additional resources

See Readme files in the [Security-Guard Github Repository](http://knative.dev/security-guard).
