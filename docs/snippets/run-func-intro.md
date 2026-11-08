<!-- Snippet used in the following topics:
- versioned/getting-started/build-run-deploy-func.md
- versioned/functions/running-functions.md
-->
Running a function starts it in your local environment without deploying it to a cluster. Containerized runs build an OCI image if needed; supported host-based runs use the local language toolchain instead. Neither path publishes an image by default. Local testing lets you exercise the handler before deployment.
