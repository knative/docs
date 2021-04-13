
## What are revisions?
You may have noticed in the last step, that when your Knative Service was created, Knative returned both a URL and a 'latest revision' for your Service.

You can think of a `Revision` as a stateless, autoscaling snapshot-in-time of application code and configuration. A new `Revision` will get created each and every time you make changes to your Knative Service.
