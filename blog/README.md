# Updating the Knative Blog

The Knative website has a basic, top-level navigation that looks like this:

```yaml
nav:
    - Home:
    - Tutorial:
    - Installing:
    - Serving:
    - Eventing:
    - Code samples:
    - Reference:
    - Community:
    - About:
    - Blog:
```

Currently, we maintain two different copies of the navigation.

## docs/config/nav.yml

The main one, for the website as a whole, is located at [`docs/config/nav.yml`](docs/config/nav.yml) and contains the links for all the subject matter except for the Blog and Community pages. It uses relative links for everything except the Blog / Community, for example:

```yaml
    - Tutorial:
        - Knative Quickstart: getting-started/README.md
        - Using Knative Serving:
          - First Knative Service: getting-started/first-service.md
          - Scaling to Zero: getting-started/first-autoscale.md
          - Traffic Splitting: getting-started/first-traffic-split.md
```

Note here that each link assumes that the present working directory is `docs/docs/`, so for example the "Tutorial" README which is located in `docs/docs/getting-started/README.md` is listed as `getting-started/README.md`

The Blog pages instead use absolute links to its sections:

```yaml
    - About:
      - Testimonials: about/testimonials.md
      - Case studies:
        - deepc: about/case-studies/deepc.md
        - Outfit7: about/case-studies/outfit7.md
        - Puppet: about/case-studies/puppet.md
    - Blog: /blog/
```

Note that the Blog link is `/blog/` and not `blog/` (and similar for the community site).

## docs/blog/config/nav.yml

The blog is actually a separate, self-contained site that is accessible from the main docs page. We do this partly because the blog is not versioned like the docs (i.e. tied to a specific release) and partly to make the left sidebar navigation look clean (i.e. only display blog posts on the blog site).

In order to do this, we essentially have a separate mkdocs site for the blog that gets copied over into the main site. This is done using the [`hack/build.sh` script](https://github.com/knative/docs/blob/main/hack/build.sh#L84-L90). While we try to copy over as many files as possible from the main site (to avoid duplicating configuration / html / stylesheets / etc), our [`nav.yml` file](docs/blog/config/nav.yml) (located at `docs/blog/config/nav.yml`) is unique to the blog site.

```yaml
nav:
    - Home: /docs/
    - Tutorial: /docs/getting-started/
    - Installing: /docs/install/
    - Serving: /docs/serving/
    - Eventing: /docs/eventing/
    - Code samples: /docs/samples/
    - Reference: /docs/reference/
    - Community: /docs/community/
    - About: /docs/about/testimonials
    - Blog:
      - index.md
      - Releases:
          - releases/announcing-knative-v0-26-release.md
          - releases/announcing-knative-v0-25-release.md
          - releases/announcing-knative-v0-24-release.md
            ...
```

A couple of key points:

* The basic, high-level sections are the same as for the main site (Home, Tutorial, etc.).

* The blog requires absolute links for all sections not in the blog. For example, the Tutorial section link is `/docs/getting-started/` for the blog site (whereas it was simply `getting-started/` for the main site). Also note that for the blog, we don't need to link to a specific file, as each of those directories has a README that gets redirected to.

* For the blog, we use relative links, with `docs/blog/docs/` as the present working directory.

## Updating the blog

When a new blog post is created, it will also need to be added to the blog navigation (i.e. to `docs/blog/config/nav.yml`) in the appropriate section.

## Updating the site navigation

If a major change to the site navigation is made (for example, adding a new section to the top navigation tabs), then the change will need to be made in both `docs/config/nav.yml` and `docs/blog/config/nav.yml`.

For changes that are not top-level (i.e. adding a subsection to the "Tutorial" guide or creating a new category of blog post), the change only needs to be made in the relevant section, as it's invisible to the other (for example, the subsection of the "Tutorial" guide only needs to be made in `docs/config/nav.yml`)

## Common files between main site and blog, also known as non nav.yml files

All files in `docs/overrides`, `docs/images`, and `docs/stylesheets` are copied to the blog at build-time.

What this means is that any changes to files in those directories (for example, updating the main site layout editing `docs/stylesheets/extra.css`) will go live _on the blog_ as soon as those changes are pushed to `main`. In contrast, on the main site those changes will appear in the development branch and only go live when they are cherry-picked into the current release branch.
