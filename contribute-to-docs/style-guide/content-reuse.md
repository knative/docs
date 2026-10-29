# Content Reuse

Knative strives to reduce duplicative effort by reusing commonly used information,
see the [`docs/snippets`](https://github.com/knative/docs/tree/main/docs/snippets) directory for some examples.

Snippets do not require a specific extension, and as long as a valid file name is
specified, an attempt is made to process it.

Snippets can handle recursive file inclusion.
If Snippets encounters the same file in the current stack, it avoids re-processing
it to avoid an infinite loop or crash on hitting max recursion depth.

## Versioning and release fixes

Snippets in `docs/snippets/` are versioned with the documentation's Git branches.
Each published documentation version uses the snippets from its matching release
branch, not the latest snippets from `main`. Development documentation and local
previews use the current checkout's snippets. Unversioned pages, such as community
pages, also use the current checkout's snippets.

Keep include paths relative to `docs/snippets/`; do not add version numbers:

```markdown
--8<-- "install-kn.md"
```

Jinja includes, such as `{% include "event-display.md" %}`, follow the same
version selection. Nested includes stay within the same version as the page.
Missing snippets fail the build rather than falling back to another version.

To fix a snippet in an already published release, backport the change to that
release's `docs/snippets/` directory, just as you would for a documentation page.
A change on `main` alone will not update released documentation.

To check a backport before it merges, preview the release branch on its own
(for example, run `./hack/mkdocs.sh` from a checkout of that branch); a
single-branch preview always uses its own snippets. The full multi-version build
(`./hack/build.sh`) fetches release branches from the Git remote, so it only
shows a backport after it has merged.

For more info, see the [PyMdown Extensions Documentation](https://facelessuser.github.io/pymdown-extensions/extensions/snippets/)
