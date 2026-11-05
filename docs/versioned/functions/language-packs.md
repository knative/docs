---
audience: developer
components:
  - functions
function: how-to
---

# Language packs

Language packs can be used to extend Knative Functions to support additional runtimes, function signatures, operating systems, and installed tooling for functions. Language Packs are distributed through Git repositories or as a directory on a disc.

For more information see the [language pack](https://github.com/knative/func/blob/main/docs/language-packs/language-pack-contract.md){target=_blank} documentation.

## Using external Git repositories

When creating a new function, a Git repository can be specified as the source
for the template files.

## Installing language packs locally

Language packs can be installed locally by using the [`func repository`](https://github.com/knative/func/blob/main/docs/reference/func_repository.md){target=_blank} command.
