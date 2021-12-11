# Content Reuse

Knative strives to reduce duplicative effort by reusing commonly used information,
see the [`docs/snippets`](https://github.com/knative/docs/tree/main/docs/snippets) directory for some examples.

Snippets do not require a specific extension, and as long as a valid file name is
specified, an attempt is made to process it.

Snippets can handle recursive file inclusion.
If Snippets encounters the same file in the current stack, it avoids re-processing
it to avoid an infinite loop or crash on hitting max recursion depth.

For more info, see the [PyMdown Extensions Documentation](https://facelessuser.github.io/pymdown-extensions/extensions/snippets/)
