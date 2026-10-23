FROM ghcr.io/astral-sh/uv:0.9.5 AS uv
FROM python:3.13-slim

# git and curl are only needed for the optional full release build.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /usr/local/bin/uv
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_DOWNLOADS=never \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /site
COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --locked --no-dev --no-cache

ENTRYPOINT ["mkdocs"]
CMD ["serve", "--livereload", "--config-file", "mkdocs.local.yml", "--dev-addr", "0.0.0.0:8000"]
