# Snippets

This folder is for commonly used bits of information that need a single source of truth. Some examples include:

1. Code blocks that may be used in several locations
2. Topics that may need to be included in multiple places (e.g. "create a service")
3. **Use your best judgement, wherever content needs to be re-used easily across the site**

Snippets are versioned with the documentation's Git branches. Published release
pages use `docs/snippets/` from the matching release branch; development pages
and local previews use the current checkout. Backport snippet fixes to any
release branches that need them. Keep include paths relative to this directory,
without version numbers. Both PyMdown and Jinja includes follow this rule.

For information on how to use Snippets, see [the pymdown-extension documentation](https://facelessuser.github.io/pymdown-extensions/extensions/snippets/)
