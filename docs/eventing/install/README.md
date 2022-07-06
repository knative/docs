# Install Eventing

--8<-- "installing-eventing-intro.md"
--8<-- "prerequisites.md"
<!-- TODO: Link to provisioning guide for advanced installation -->

## YAML
- Install Knative with YAML:
  - Install Knative Eventing:
    - Install Eventing with YAML: install/yaml-install/eventing/install-eventing-with-yaml.md
    - Knative Eventing installation files: install/yaml-install/eventing/eventing-installation-files.md

    <!--TODO: redirect these to new sections-->

    # Operator Installation
      - Configuring Knative using the Operator: install/operator/configuring-with-operator.md
      - Configuring Knative Eventing CRDs: install/operator/configuring-eventing-cr.md

## Installing Eventing by using the Operator

--8<-- "about-knative-operator.md"
--8<-- "install-operator.md"

### Installing the Knative Eventing component

After you have installed the Knative Operator, you must create the `KnativeEventing` custom resource (CR).

<h4>Procedure</h4>

1. Copy the following YAML into a file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: knative-eventing
    ---
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeEventing
    metadata:
      name: knative-eventing
      namespace: knative-eventing
    ```

1. Apply the YAML file to create the `knative-eventing` namespace and the `KnativeEventing` CR in that namespace, by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

#### Verify the Knative Eventing deployment

1. Monitor the Knative deployments:

    ```bash
    kubectl get deployment -n knative-eventing
    ```

    If Knative Eventing has been successfully deployed, all deployments of the
    Knative Eventing will show `READY` status. Here is a sample output:

    ```{.bash .no-copy}
    NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller     1/1     1            1           43s
    eventing-webhook        1/1     1            1           42s
    imc-controller          1/1     1            1           39s
    imc-dispatcher          1/1     1            1           38s
    mt-broker-controller    1/1     1            1           36s
    mt-broker-filter        1/1     1            1           37s
    mt-broker-ingress       1/1     1            1           37s
    pingsource-mt-adapter   0/0     0            0           43s
    sugar-controller        1/1     1            1           36s
    ```

1. Check the status of Knative Eventing Custom Resource:

    ```bash
    kubectl get KnativeEventing knative-eventing -n knative-eventing
    ```

    If Knative Eventing is successfully installed, you should see:

    ```{.bash .no-copy}
    NAME               VERSION             READY   REASON
    knative-eventing   <version number>    True
    ```
