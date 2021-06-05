# Development notes for working with mkdocs

You can use a Docker container and run MkDocs from the container, so no local installation of mkdocs is required:

- You need to have [Docker](https://www.docker.com) installed and running on your system
- There are helper configurations installed if you have npm from [Node.JS](https://nodejs.org) installed.
- Build the development docker container image, this is only need it once if the dependencies have not changed.
    ```bash
    npm run dev:build
    ```
- To start developing run command the following command in the root directory of the git repo (where **package.json** and **mkdocs.yaml** are located)
    ```bash
    npm run dev
    ```
- Open a browser to http://localhost:8000, where you will see the documentation site.  This will live update as you save changes to the Markdown files in the `docs` directory.
- To stop developing run the following command in another terminal window, which will terminate the docker container
    ```bash
    npm run dev:stop
    ```
- To build the static HTML files including both mkdocs and hugo run the following command.
    ```bash
    npm test
    ```
- To view additional npm scripts run the following command
    ```bash
    npm run
    ```


