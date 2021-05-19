
All information about contributing to the Knative documentation has been moved
into a single location:

#### [Go to the How-to guides for Knative docs contributors](https://knative.dev/help/)

**Quick links**:
   * [Docs help](https://knative.dev/help/contributor/)
      * New content templates:
        * [Documentation](https://github.com/knative/docs/tree/main/template-docs-page.md) -- Instructions and a template that
          you can use to help you add new documentation.
        * [Blog](https://github.com/knative/docs/tree/main/template-blog-page.md) -- Instructions and a template that
          you can use to help you post to the Knative blog.
   * [Website help](https://knative.dev/help/contributor/publishing)
   * [Maintainer help](https://knative.dev/help/maintainer/)


# MkDocs Contributions (Beta)
**This is a temporary home for contribution guidelines for the MkDocs branch. When MkDocs becomes "main" this will be moved to the appropriate place on the website (the places linked above)**


##Install Material for MkDocs
Knative.dev uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) to render documentation. Material for MkDocs is Python based and uses pip to install most of it's required packages as well as optional add-ons (which we use)

You can choose to install MkDocs locally or using a Docker image. pip actually comes pre-installed with Python so it is included in many operating systems (like MacOSx or Ubuntu) but if you don’t have python, you can install it here: https://www.python.org/  

=== "pip"
pip install mkdocs-material
For some (e.g. folks using RHEL), you may have to use pip3.

==="pip3"
pip3 install mkdocs-material
