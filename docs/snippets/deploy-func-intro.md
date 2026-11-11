<!-- Snippet used in the following topics:
- versioned/getting-started/build-run-deploy-func.md
- versioned/functions/deploying-functions.md
-->
Deploying a function normally builds an OCI image when needed, publishes it to your configured registry, and creates or updates a Knative Service on the selected cluster. Build and push can be disabled when using an already published image. A deployed function uses the same routing and access configuration as other Knative Services; publishing an image alone does not deploy it.
