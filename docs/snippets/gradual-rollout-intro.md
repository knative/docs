# Configuring gradual rollout of traffic to Revisions

If your traffic configuration points to a Configuration target instead of a Revision target, when a new Revision is created and ready, 100% of the traffic from the target is immediately shifted to the new Revision.

This might make the request queue too long, either at the QP or Activator, and cause the requests to expire or be rejected by the QP.
<!--QUESTION: QP == queue proxy?-->

Knative provides a `rollout-duration` parameter, which can be used to gradually shift traffic to the latest Revision, preventing requests from being queued or rejected. Affected Configuration targets are rolled out to 1% of traffic first, and then in equal incremental steps for the rest of the assigned traffic.

!!! note
    `rollout-duration` is time-based, and does not interact with the autoscaling subsystem.

This feature is available for tagged and untagged traffic targets, configured for either Knative Services or Routes without a service.
