# Previewing the website locally

The Knative website uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
to render documentation.

If you don't want to use any tool locally, you can use [GitPod](https://gitpod.io/#https://github.com/knative/docs)
this will allow you to edit the files on a Web IDE and live preview.

If you choose to run the site locally, we strongly recommend using a container.

Regardless of the method used, when you submit a PR, a live preview link will be available in a comment on the PR.

## (Option 1): Use the Docker container

You can use [Docker Desktop](https://www.docker.com/products/docker-desktop) or any docker engine supported for your operating system that is compatible with the `docker` CLI, for example [colima](https://github.com/abiosoft/colima).

### Live preview

To start the live preview, run the following script from the root directory of your local Knative docs repo:
```
./hack/docker/run.sh
```
Then open a web browser on http://localhost:8000

You can edit any file under `./docs` and the live preview autoreloads.

When you're done with your changes, you can stop the container using `Ctrl+C`.


### Full site build (optional)

To run a complete build of the website with all versions, run the following script from the root directory of your local Knative docs repo:
```
./hack/docker/test.sh
```
The build output is the entire static site located in `./site`.

You can preview the website locally by running a webserver using this directory like `npx http-server site -p 8000` if you have Node.js or `python3 -m http.server 8000` if you have Python 3.

To run this script, you will need to set the `GITHUB_TOKEN` environmental variable to your [Github Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).


## (Option 2) Using native Python mkdocs CLI

The website is built using [material-mkdocs](https://squidfunk.github.io/mkdocs-material/) which is a python tool based
on the `[mkdocs](https://www.mkdocs.org/) project.

### Install Material for MkDocs locally

Material for MkDocs is Python based and uses pip to install most of its required
packages, as well as the optional add-ons we use.
pip comes pre-installed with Python so it's included in many operating
systems (like macOS or Ubuntu) but if you don’t have Python, you can install it
from the [Python website](https://www.python.org).

For some (e.g. folks using RHEL), you might have to use pip3.

Install Material for MkDocs and dependencies by running:

```
pip install -r requirements.txt
```

For more detailed instructions, see [Material for MkDocs documentation](https://squidfunk.github.io/mkdocs-material/getting-started/#installation)


If you have `pip3` you can use the above commands and replace `pip` with `pip3`

### Setting up local preview

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
    If you’re only changing a single page in the `/docs/` folder that is not the homepage or `nav.yml`, adding the flag `--dirtyreload` makes the site rebuild faster.

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
