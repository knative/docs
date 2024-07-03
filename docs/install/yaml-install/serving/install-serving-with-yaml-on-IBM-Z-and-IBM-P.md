# Customizing 3-scale-kourier-gateway on IBM Z and IBM P platform

To run 3-scale-kourier-gateway on IBM Z and IBM P platforms, find the latest available image from the following [redhat catalog](https://catalog.redhat.com/software/containers/openshift-service-mesh/proxyv2-rhel8/5d2cda455a134672890f640a). Check the latest tag and click on the get this image tag to copy the image name. 

!!! tip
    You can create [redhat developer account](developers.redhat.com/register) and authenticate to pull images from redhat catalog.

```
kubectl patch deployment 3scale-kourier-gateway -n kourier-system -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"kourier-gateway","image":"<replace the proxyv2 image here>"}]}}}}'
```
Please refer to the page to [configure pull secrets](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account)

All other steps for installation remains same as described in rest of the documentation.