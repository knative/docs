# Previewing the website locally

The Knative website uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
to render documentation.
You can choose to install MkDocs locally or use a Docker image.

## Install Material for MkDocs locally

Material for MkDocs is Python based and uses pip to install most of its required
packages, as well as the optional add-ons we use.
pip comes pre-installed with Python so it's included in many operating
systems (like macOS or Ubuntu) but if you don’t have Python, you can install it
from the [Python website](https://www.python.org).

For some (e.g. folks using RHEL), you might have to use pip3.

### Install using pip

1. Install Material for MkDocs by running:

    ```
    pip install mkdocs-material
    ```

    For more detailed instructions, see [Material for MkDocs documentation](https://squidfunk.github.io/mkdocs-material/getting-started/#installation)

1. Install the extensions to MkDocs needed for Knative by running:

    ```
    pip install mkdocs-material-extensions mkdocs-macros-plugin mkdocs-exclude mkdocs-awesome-pages-plugin mkdocs-redirects
    ```

### Install using pip3

1. Install Material for MkDocs by running:

    ```
    pip3 install mkdocs-material
    ```

    For more detailed instructions, see the [Material for MkDocs documentation](https://squidfunk.github.io/mkdocs-material/getting-started/#installation)

1. Install the extensions to MkDocs needed for Knative by running:

    ```
    pip3 install mkdocs-material-extensions mkdocs-macros-plugin mkdocs-exclude mkdocs-awesome-pages-plugin mkdocs-redirects
    ```

## Use the Docker container
//TODO DOCKER CONTAINER EXTENSIONS

## Setting up local preview

When using the local preview, anytime you change any file in your local copy of
the `/docs` directory and hit save, the site automatically rebuilds to reflect your changes!

To preview the docs locally:

1. After you have installed Material for MkDocs and all of the extensions, head over
to the [Knative docs GitHub repository](https://github.com/knative/docs/tree/main)
and clone the repo.

1. In your terminal, go to the directory of the cloned repo.

1. Start the preview by running one of the following commands:
    - **Local Preview**

      ```
      mkdocs serve
      ```

    - **Local Preview with Dirty Reload**
    If you’re only changing a single page in the `/docs/` folder that is not the homepage or `nav.yml`, adding the flag `--dirtyreload` makes the site rebuild super crazy insta-fast.

      ```
      mkdocs serve --dirtyreload
      ```

    When the preview has built, you'll see the following:

    ```{ .bash .no-copy }
    ...
    INFO    -  Documentation built in 13.54 seconds
    [I 210519 10:47:10 server:335] Serving on http://127.0.0.1:8000
    [I 210519 10:47:10 handlers:62] Start watching changes
    [I 210519 10:47:10 handlers:64] Start detecting changes
    ```

1. Open the local preview by accessing http://127.0.0.1:8000. You should see the site is built! 🎉


## Setting Up "Public" Preview

If, for whatever reason, you want to share your work before submitting a PR (where Netlify generates a preview for you), you can deploy your changes as a Github Page by running the command:

```
mkdocs gh-deploy --force
```

Expected output:

```{ .bash .no-copy }
INFO    -  Documentation built in 14.29 seconds
WARNING -  Version check skipped: No version specified in previous deployment.
INFO    -  Copying '/Users/omerbensaadon/Documents/GitHub/MergeConflictsResolve/docs/site' to 'gh-pages' branch and pushing to GitHub.
INFO    -  Your documentation should shortly be available at: https://<your-github-handle>.github.io/docs/
```
Where `<your-github-handle>` is your Github handle.

After a few moments, your changes should be available for public preview at the link provided by MkDocs. This means you can rapidly prototype and share your changes before making a PR!
