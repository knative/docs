# Editing the website navigation and redirects

## Navigation

Navigation in the Knative website is defined in the [`/config/nav.yml`](../../config/nav.yml) file.

The backend looks as follows:

![Screenshot of the getting started section in the nav.yml file](../images/nav-backend.png)

The frontend looks as follows:

![Screenshot of the getting started section in the website navigation menu](../images/nav-frontend.png)

For more in-depth information on navigation, see:
[Configure Pages and Navigation](https://www.mkdocs.org/user-guide/writing-your-docs/#configure-pages-and-navigation)
in the MkDocs documentation and
[Setting up Navigation](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/)
in the Material for MkDocs documentation.

### Redirects

The Knative site uses [mkdocs-redirects](https://github.com/datarobot/mkdocs-redirects)
to redirect users from a page that may no longer exist (or has been moved) to their desired location.

Adding redirects to the Knative site is done in one centralized place,
[`/config/redirects.yml`](../../config/redirects.yml).
The format is shown here:

```
plugins:
  redirects:
    redirect_maps:
        ...
        path_to_old_or_moved_URL : path_to_new_URL
```
