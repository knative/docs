# Revisions

--8<-- "about-revisions.md"

## Related concepts

* **[Autoscaling](../../serving/autoscaling/README.md){target=_blank}**
    - Revisions can be automatically scaled up and down according to incoming traffic.

* **[Configuring gradual rollout of traffic to Revisions](../../serving/rolling-out-latest-revision.md){target=_blank}**
    - Revisions enable progressive roll-out and roll-back of application changes.
<!--
- **Garbage collection**
    - TODO: add Something about how this works w/ revisions; only apply for Operator installs? GC docs need a general cleanup before adding something / links here-->

## Additional resources

- [Revision API specification](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#revision){target=_blank}

## Next steps

- [Delete, describe, and list Revisions by using the Knative (`kn`) CLI](https://github.com/knative/client/blob/main/docs/cmd/kn_revision.md){target=_blank}
- [Check the status of a Revision](../../serving/troubleshooting/debugging-application-issues.md#check-revision-status){target=_blank}
- [Routing traffic between Revisions of a Service](../../serving/traffic-management.md#traffic-routing-examples){target=_blank}
<!--TODO:
- Configuration options for Revisions
    - Cluster administrator (global) configuration options
    - Developer (per Revision) configuration options
-->
