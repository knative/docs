# Prerequisites

## Tools

You'll need these tools installed:

*   git
*   golang
*   make
*   [dep](https://github.com/golang/dep)
*   [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)
*   [kustomize](https://github.com/kubernetes-sigs/kustomize)
*   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
    (optional)
*   [minikube](https://github.com/kubernetes/minikube) (optional)

## Create a git repo

Create a git repo locally in the proper GOPATH location . For the reference
project, that's `$GOPATH/src/github.com/grantr/sample-source`.

```sh
cd $GOPATH/src/github.com/grantr
git init sample-source
```

Create an empty initial commit.

```sh
git commit -m "Initial commit" --allow-empty
```

Next: [Bootstrap](02-bootstrap.md)
