---
audience: administrator
components:
  - serving
function: how-to
---

# Install a networking layer on IBM Z and IBM Power platforms

This additional step is required for installing the Kourier networking layer on IBM Z and IBM Power platforms.

Once you completed installing Kourier,  patch the envoy image as described below. Use the envoy image included as part of the [RedHat Maistra](https://maistra.io/) distribution. Maistra is an opinionated distribution of Istio designed to work with OpenShift and is supported on IBM Z and IBM Power platforms.

1. Find the image name to use:  
    1. Access the [redhat catalog](https://catalog.redhat.com/software/containers/openshift-service-mesh/proxyv2-rhel8/5d2cda455a134672890f640a) 
    2.  Choose the appropriate architecture (ppc64le/s390x) from the architecture drop down. 
    3. Choose the latest tag from the list of available tags at the tag dropdown.
    4. Click on the "get this image" tab and copy the image name. For example: `registry.redhat.io/openshift-service-mesh/proxyv2-rhel8@sha256:ced904...`

2. Patch the **3scale-kourier-gateway**  deployment in **kourier-system** namespace with latest available image using **kubectl** as shown below.

  ```bash
    kubectl patch deployment 3scale-kourier-gateway -n kourier-system -p \
    '{"spec":{"template":{"spec":{"containers":[{"name":"kourier-gateway" "image":"<the proxyv2 image name>"}]}}}}'
  ```

!!! note
    1. If there are authentication issues, create [redhat developer account](developers.redhat.com/register) to pull images from redhat catalog. 
    2. Please refer to the page to [configure pull secrets](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account)