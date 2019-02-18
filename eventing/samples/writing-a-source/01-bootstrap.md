<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Bootstrap the Project](#bootstrap-the-project)
  - [Create a git repo](#create-a-git-repo)
  - [Create a Kubebuilder project](#create-a-kubebuilder-project)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Bootstrap the Project

We'll use Kubebuilder to bootstrap the project and provide common controller
boilerplate and scaffolding. Check out the
[Kubebuilder book](https://book.kubebuilder.io/) to learn more about
Kubebuilder.

## Create a git repo

Create a git repo locally in the proper GOPATH location. For the reference
project, that's `$GOPATH/src/github.com/grantr/sample-source`.

```sh
cd $GOPATH/src/github.com/grantr
git init sample-source
```

Create an empty initial commit.

```sh
git commit -m "Initial commit" --allow-empty
```

## Create a Kubebuilder project

_When in doubt, the
[Kubebuilder Quick Start docs](https://book.kubebuilder.io/quick_start.html) are
likely more current than these instructions._

Use the `kubebuilder init` command in the repo root directory to create the
basic project structure.

You'll need to choose the following:

- **A license.** The reference project uses Apache 2.
- **A domain name.** This is the unique domain used to identify your project's
  resources. The reference project uses `knative.dev`, but you should choose one
  unique to you or your organization.
- **An author name.** This is the copyright owner listed in the copyright notice
  at the top of each source file. The reference project uses
  `The Knative Authors.`

```sh
kubebuilder init --domain knative.dev --license apache2 --owner "The Knative Authors"
```

This command will ask if you want to run `dep ensure`. Choose yes to populate
your project's vendor directory.

The result of this command in the reference project can be viewed at
https://github.com/grantr/sample-source/pull/1.

Next: [Define The Source Resource](02-define-source.md)
