#!/usr/bin/env bash
# The cluster is disposable: collect every pod, regardless of application labels.
kubectl get ksvc,revisions,pods -A -o wide || true
kubectl get events -A --sort-by=.metadata.creationTimestamp || true
kubectl get pods -A -o json | jq -r \
  '.items[] | [.metadata.namespace, .metadata.name] | @tsv' |
  while IFS=$'\t' read -r namespace pod; do
    printf '\n=== %s/%s ===\n' "$namespace" "$pod"
    kubectl -n "$namespace" logs "$pod" --all-containers --tail=100 || true
  done
