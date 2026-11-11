<!-- Snippet used in the following topics:
- versioned/functions/deploying-functions.md
- versioned/functions/building-functions.md
- versioned/functions/subscribing-functions.md
-->
`func` uses the effective kubeconfig and its **current context**. Running a `kubectl` or `kn` check with `--context` does not select that context for a later `func` command. Neither `--remote=false` nor `invoke --target=remote` selects a cluster.

In every shell used for cluster-facing Functions commands, select a trusted kubeconfig file and set the expected context and namespace. Replace all three example values with your intended environment; use a single kubeconfig file for this procedure, not a merged file list:

```bash
export KUBECONFIG=/absolute/path/to/intended-kubeconfig
EXPECTED_CONTEXT=your-intended-context
NAMESPACE=your-namespace

check_func_context() {
  if [ -z "$EXPECTED_CONTEXT" ] || [ -z "$NAMESPACE" ]; then
    printf '%s\n' 'STOP: set the intended context and namespace.' >&2
    return 1
  fi
  if [ ! -f "$KUBECONFIG" ]; then
    printf '%s\n' 'STOP: intended kubeconfig file is missing.' >&2
    return 1
  fi
  actual_context=$(kubectl config current-context) || return 1
  if [ "$actual_context" != "$EXPECTED_CONTEXT" ]; then
    printf '%s\n' 'STOP: kubeconfig current context does not match the intended context.' >&2
    return 1
  fi
}

check_func_context
```

Stop on failure. Do not deploy or invoke remotely until the effective current context matches the intended cluster. Confirm that the selected file/context belongs to that cluster using information from your operator or provider; see [CLI connection guidance](../client/connect-to-cluster.md). Do not change the user's default kubeconfig to make a check pass.

Keep `KUBECONFIG` set and use `check_func_context &&` before each cluster-facing `func` or `kn func` command, as below. If you open another terminal, repeat this setup there. The guard checks context selection, not resource ownership or authorization.
