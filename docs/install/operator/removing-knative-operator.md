# Uninstalling Knative Operator

Knative Operator prevents unsafe removal of Knative resources. Even if the Knative Serving and Knative Eventing CRs are
successfully removed, all the CRDs in Knative are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

## Removing the Knative Serving component

To remove the Knative Serving CR run the command:

```bash
kubectl delete KnativeServing knative-serving -n knative-serving
```

## Removing Knative Eventing component

To remove the Knative Eventing CR run the command:

```bash
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

## Removing the Knative Operator:

If you have installed Knative using the release page, remove the operator by running the command:

```bash
kubectl delete -f {{artifact(org="knative",repo="operator",file="operator.yaml")}}
```

If you have installed Knative from source, uninstall it using the following command while in the root directory
for the source:

```bash
ko delete -f config/
```

## What's next

- [Configure Knative Serving using Operator](configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](configuring-eventing-cr.md)
