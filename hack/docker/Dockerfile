FROM python:3.13-slim

# git and curl are only needed for the optional full release build.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_DOWNLOADS=never \
    PATH="/opt/venv/bin:$PATH" \
    NO_MKDOCS_2_WARNING=1

WORKDIR /site
COPY pyproject.toml uv.lock .python-version ./
COPY hack/uv_version.py hack/uv_version.py
RUN python3 -m pip install --no-cache-dir "uv==$(python3 hack/uv_version.py)" \
    && uv sync --locked --no-dev --no-cache

ENTRYPOINT ["mkdocs"]
CMD ["serve", "--livereload", "--config-file", "mkdocs.local.yml", "--dev-addr", "0.0.0.0:8000"]
