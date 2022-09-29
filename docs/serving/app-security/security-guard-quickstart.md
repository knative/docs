# Security-Behavior Monitoring Quickstart  - WIP

DOCS EDITORS - This page is crafted after:
https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started-with-guard 

To understand what Secuity-Guard is used for - See [About Security Guard](../about-security-guard.md)

In this tutorial, deploy a Hello World service and protect it with Guard.

Before you begin:

1. WE NEED TO EXPLAIN HERE HOW TO DEPLOY QUEUE PROXY IMAGE ENHACED BY SECURITY_GUARD - @psschwei, @argent
2. Make sure to follow the regular [service creation quickstart](../services/creating-services.md)


Step 1: Deploy a guard-service in the namespace

Guard-service learns the necessary micro-rules for each Guard-protected service in a namespace. Deploy a Guard-service in each namespace where you run Knative services that need to be protected.

DESCRIBE HERE HOW TEH USER WILL DEPLOY Guard-service

Step 2: Creating and deploying a protected Hello World application

REPEAT HERE THE NEEDED PARTS FROM https://knative.dev/docs/serving/services/creating-services/

Step 3: Managing the security of the Hello World application and gaining situational awareness

Guard offers situational awareness into the application security posture. You can find security alerts in the log file of Guard, as they occur.

SHOW HOW TO GET QUEUE-PROXY LOGS

Example output

[...]
{"level":"warn","message":"SECURITY ALERT! HttpRequest: Headers: KeyVal: Known Key X-B3-Traceid: Digits: Counter out of Range: 25"}  
[...]
Security alerts appear as warnings in the guard log file and start with the string SECURITY ALERT!. The default setup of Guard is to allow any request or response and learn any new pattern after reporting it. When the application is actively serving requests, it typically takes about 30 min for Guard to learn the patterns of the application requests and responses and build corresponding micro-rules. After the initial learning period, Guard sends alerts only when a change in behavior is detected.

Note that in the default setup, Guard continues to learn any new behavior and therefore avoids reporting alerts repeatedly when the new behavior reoccurs. Correct security procedures should include reviewing any new behavior detected by Guard.

Guard can also be configured to operate in other modes of operation, such as:

Move from auto learning to manual micro-rules management after the initial learning period
Block requests/responses when they do not conform to the micro-rules
For more information or for troubleshooting help, see the #security channel.
