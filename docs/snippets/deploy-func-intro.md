<!-- Snippet used in the following topics:
- /docs/getting-started/build-run-deploy-func.md
- /docs/functions/deploying-functions.md
-->
Deploying a function creates an OCI container image for your function, and pushes this container image to your image registry. The function is deployed to the cluster as a Knative Service. Redeploying a function updates the container image and resulting Service that is running on your cluster. Functions that have been deployed to a cluster are accessible on the cluster just like any other Knative Service.
