# Supported Operator component versions

The following table describes the supported versions of Serving and Eventing for the Knative Operator:

| Operator | Serving                                                    | Eventing                                                                                         |
|----------|------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| v1.6.0   | v1.6.0<br/>v1.5.0<br/>v1.4.0<br/>v1.3.0, v1.3.1 and v1.3.2 | v1.6.0<br/>v1.5.0 and v1.5.1<br/>v1.4.0, v1.4.1 and v1.4.2<br/>v1.3.0, v1.3.1, v1.3.2 and v1.3.3 |

!!! warning
    Knative Operator 1.5 is the last version that supports CRDs with both `v1alpha1` and `v1beta1`. If you are upgrading an existing Operator install from v1.2 or earlier to v1.3 or later, run the following command to upgrade the existing custom resources to `v1beta1` before installing the current version:

    ```bash
    kubectl create -f https://github.com/knative/operator/releases/download/knative-v1.5.1/operator-post-install.yaml
    ```

You can find information about the released versions of the Knative Operator on the [releases page](https://github.com/knative/operator/releases).
