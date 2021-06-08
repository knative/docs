#!/bin/sh

PORT=${2:-8000}

mkdocs serve --config-file "./mkdocs.yml" --livereload -a 0.0.0.0:${PORT}
