# Using Security-Guard

Here we discuss managing the security of a service using Security-Guard.

Security-Guard offers situational awareness by writing its alerts to the Service queue proxy log. You may observe the queue-proxy to see alerts.

Security alerts appear in the queue proxy log file and start with the string `SECURITY ALERT!`. The default setup of Security-Guard is to allow any request or response and learn any new pattern after reporting it. When the Service is actively serving requests, it typically takes about 30 min for Security-Guard to learn the patterns of the Service requests and responses and build corresponding micro-rules. After the initial learning period, Security-Guard updates the micro-rules in the Service Guardian, following which, it sends alerts only when a change in behavior is detected.

Note that in the default setup, Security-Guard continues to learn any new behavior and therefore avoids reporting alerts repeatedly when the new behavior reoccurs. Correct security procedures should include reviewing any new behavior detected by Security-Guard.

Security-Guard can also be configured to operate in other modes of operation, such as:

* Move from auto learning to manual micro-rules management after the initial learning period
* Block requests/responses when they do not conform to the micro-rules

For more information or for troubleshooting help, see the [#security](https://knative.slack.com/archives/CBYV1E0TG) channel in Knative Slack.
