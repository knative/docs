---
title: "Authentication"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 25
type: "docs"
---

This document defines how authentication is provided during execution of a
build.

The build system supports two types of authentication, using Kubernetes'
first-class `Secret` types:

- `kubernetes.io/basic-auth`
- `kubernetes.io/ssh-auth`

Secrets of these types can be made available to the `Build` by attaching them to
the `ServiceAccount` as which it runs.

### Exposing credentials to the build

In their native form, these secrets are unsuitable for consumption by Git and
Docker. For Git, they need to be turned into (some form of) `.gitconfig`. For
Docker, they need to be turned into a `~/.docker/config.json` file. Also, while
each of these supports has multiple credentials for multiple domains, those
credentials typically need to be blended into a single canonical keyring.

To solve this, before the `Source` step, all builds execute a credential
initialization process that accesses each of its secrets and aggregates them
into their respective files in `$HOME`.

## SSH authentication (Git)

1.  Define a `Secret` containing your SSH private key:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: ssh-key
      annotations:
        build.knative.dev/git-0: https://github.com # Described below
    type: kubernetes.io/ssh-auth
    data:
      ssh-privatekey: <base64 encoded>
      # This is non-standard, but its use is encouraged to make this more secure.
      known_hosts: <base64 encoded>
    ```

    `build.knative.dev/git-0` in the example above specifies which web address
    these credentials belong to. See
    [Guiding Credential Selection](#guiding-credential-selection) below for more
    information.

1.  Generate the value of `ssh-privatekey` by copying the value of (for example)
    `cat ~/.ssh/id_rsa | base64`.

1.  Copy the value of `cat ~/.ssh/known_hosts | base64` to the `known_hosts`
    field.

1.  Next, direct a `ServiceAccount` to use this `Secret`:

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: build-bot
    secrets:
      - name: ssh-key
    ```

1.  Then use that `ServiceAccount` in your `Build`:

    ```yaml
    apiVersion: build.knative.dev/v1alpha1
    kind: Build
    metadata:
      name: build-with-ssh-auth
    spec:
      serviceAccountName: build-bot
      steps:
      ...
    ```

1.  Execute the build:

    ```shell
    kubectl apply --filename secret.yaml --filename serviceaccount.yaml --filename build.yaml
    ```

When the build executes, before steps execute, a `~/.ssh/config` will be
generated containing the key configured in the `Secret`. This key is then used
to authenticate with the Git service.

## Basic authentication (Git)

1.  Define a `Secret` containing the username and password that the build should
    use to authenticate to a Git repository:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: basic-user-pass
      annotations:
        build.knative.dev/git-0: https://github.com # Described below
    type: kubernetes.io/basic-auth
    stringData:
      username: <username>
      password: <password>
    ```

    `build.knative.dev/git-0` in the example above specifies which web address
    these credentials belong to. See
    [Guiding Credential Selection](#guiding-credential-selection) below for more
    information.

1.  Next, direct a `ServiceAccount` to use this `Secret`:

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: build-bot
    secrets:
      - name: basic-user-pass
    ```

1.  Use that `ServiceAccount` in your `Build`:

    ```yaml
    apiVersion: build.knative.dev/v1alpha1
    kind: Build
    metadata:
      name: build-with-basic-auth
    spec:
      serviceAccountName: build-bot
      steps:
      ...
    ```

1.  Execute the build:

    ```shell
    kubectl apply --filename secret.yaml --filename serviceaccount.yaml --filename build.yaml
    ```

When this build executes, before steps execute, a `~/.gitconfig` will be
generated containing the credentials configured in the `Secret`, and these
credentials are then used to authenticate with the Git repository.

## Basic authentication (Docker)

1.  Define a `Secret` containing the username and password that the build should
    use to authenticate to a Docker registry:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: basic-user-pass
      annotations:
        build.knative.dev/docker-0: https://gcr.io # Described below
    type: kubernetes.io/basic-auth
    stringData:
      username: <username>
      password: <password>
    ```

    `build.knative.dev/docker-0` in the example above specifies which web
    address these credentials belong to. See
    [Guiding Credential Selection](#guiding-credential-selection) below for more
    information.

1.  Direct a `ServiceAccount` to use this `Secret`:

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: build-bot
    secrets:
      - name: basic-user-pass
    ```

1.  Use that `ServiceAccount` in your `Build`:

    ```yaml
    apiVersion: build.knative.dev/v1alpha1
    kind: Build
    metadata:
      name: build-with-basic-auth
    spec:
      serviceAccountName: build-bot
      steps:
      ...
    ```

1.  Execute the build:

    ```shell
    kubectl apply --filename secret.yaml --filename serviceaccount.yaml --filename build.yaml
    ```

When this build executes, before steps execute, a `~/.docker/config.json` will
be generated containing the credentials configured in the `Secret`, and these
credentials are then used to authenticate with the Docker registry.

## Kubernetes's Docker registry's secret

Kubernetes defines two types of secrets for Docker registries :
`kubernetes.io/dockercfg` and `kubernetes.io/dockerconfigjson`. Knative supports
those secrets in addition to the one described above.

1. Define a `Secret` from a Docker client configuration file, as documented in
   [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

   ```bash
   kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
   ```

1. Direct a `ServiceAccount` to use this `Secret`:

   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: build-bot
   secrets:
     - name: regcred
   ```

1. Use that `ServiceAccount` in your `Build`:

   ```yaml
   apiVersion: build.knative.dev/v1alpha1
   kind: Build
   metadata:
     name: build-with-basic-auth
   spec:
     serviceAccountName: build-bot
     steps:
     ...
   ```

1. Execute the build:

   ```shell
   kubectl apply --filename secret.yaml --filename serviceaccount.yaml --filename build.yaml
   ```

When this build executes, before steps execute, a `~/.docker/config.json` will
be generated containing the credentials configured in the `Secret`, and these
credentials are then used to authenticate with the Docker registry.

If both `kubernetes.io/*` and knative flavored basic authentication secret are
provided, knative will merge the credentials from those two ; knative flavored
credentials taking precedence over `kubernetes.io/dockerconfigjson` (or
`kubernetes.io/dockercfg`) ones.

### Guiding credential selection

A build might require many different types of authentication. For instance, a
build might require access to multiple private Git repositories, and access to
many private Docker repositories. You can use annotations to guide which secret
to use to authenticate to different resources, for example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  annotations:
    build.knative.dev/git-0: https://github.com
    build.knative.dev/git-1: https://gitlab.com
    build.knative.dev/docker-0: https://gcr.io
type: kubernetes.io/basic-auth
stringData:
  username: <cleartext non-encoded>
  password: <cleartext non-encoded>
```

This describes a "Basic Auth" (username and password) secret that should be used
to access Git repos at github.com and gitlab.com, as well as Docker repositories
at gcr.io.

Similarly, for SSH:

```yaml
apiVersion: v1
kind: Secret
metadata:
  annotations:
    build.knative.dev/git-0: github.com
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: <base64 encoded>
  # This is non-standard, but its use is encouraged to make this more secure.
  # Omitting this results in the use of ssh-keyscan (see below).
  known_hosts: <base64 encoded>
```

This describes an SSH key secret that should be used to access Git repos at
github.com only.

Credential annotation keys must begin with `build.knative.dev/docker-` or
`build.knative.dev/git-`, and the value describes the URL of the host with which
to use the credential.

## Implementation detail

### Docker `basic-auth`

Given URLs, usernames, and passwords of the form: `https://url{n}.com`,
`user{n}`, and `pass{n}`, generate the following for Docker:

```json
=== ~/.docker/config.json ===
{
  "auths": {
    "https://url1.com": {
      "auth": "$(echo -n user1:pass1 | base64)",
      "email": "not@val.id",
    },
    "https://url2.com": {
      "auth": "$(echo -n user2:pass2 | base64)",
      "email": "not@val.id",
    },
    ...
  }
}
```

Docker doesn't support `kubernetes.io/ssh-auth`, so annotations on these types
are ignored.

### Git `basic-auth`

Given URLs, usernames, and passwords of the form: `https://url{n}.com`,
`user{n}`, and `pass{n}`, generate the following for Git:

```
=== ~/.gitconfig ===
[credential]
	helper = store
[credential "https://url1.com"]
    username = "user1"
[credential "https://url2.com"]
    username = "user2"
...
=== ~/.git-credentials ===
https://user1:pass1@url1.com
https://user2:pass2@url2.com
...
```

### Git `ssh-auth`

Given hostnames, private keys, and `known_hosts` of the form: `url{n}.com`,
`key{n}`, and `known_hosts{n}`, generate the following for Git:

```
=== ~/.ssh/id_key1 ===
{contents of key1}
=== ~/.ssh/id_key2 ===
{contents of key2}
...
=== ~/.ssh/config ===
Host url1.com
    HostName url1.com
    IdentityFile ~/.ssh/id_key1
Host url2.com
    HostName url2.com
    IdentityFile ~/.ssh/id_key2
...
=== ~/.ssh/known_hosts ===
{contents of known_hosts1}
{contents of known_hosts2}
...
```

Note: Because `known_hosts` is a non-standard extension of
`kubernetes.io/ssh-auth`, when it is not present this will be generated through
`ssh-keygen url{n}.com` instead.

### Least privilege

The secrets as outlined here will be stored into `$HOME` (by convention the
volume: `/builder/home`), and will be available to `Source` and all `Steps`.

For sensitive credentials that should not be made available to some steps, do
not use the mechanisms outlined here. Instead, the user should declare an
explicit `Volume` from the `Secret` and manually `VolumeMount` it into the
`Step`.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
