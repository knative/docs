# Install a networking layer on IBM Z and IBM Power platforms

  Patch the deployment **deploy/3-scale-kourier gateway in kourier-system namespace** with latest available image from [redhat catalog](https://catalog.redhat.com/software/containers/openshift-service-mesh/proxyv2-rhel8/5d2cda455a134672890f640a). Check the latest tag and click on the get this image tag to copy the image name. 

  ```bash
    kubectl patch deployment 3scale-kourier-gateway -n kourier-system -p \
    '{"spec":{"template":{"spec":{"containers":[{"name":"kourier-gateway" "image":"<replace the proxyv2 image here>"}]}}}}'
  ```

  !!! tip
      If there are authentication issues, create [redhat developer account](developers.redhat.com/register) to pull images from redhat catalog.
      Please refer to the page to [configure pull secrets](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account)