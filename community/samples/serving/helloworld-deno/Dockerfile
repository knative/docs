FROM hayd/alpine-deno:1.0.0-rc2
WORKDIR /app

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
COPY deps.ts ./
RUN deno fetch deps.ts

# These steps will be re-run upon each file change in your working directory:
COPY . ./
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno fetch main.ts

# Added to ENTRYPOINT of base image.
CMD ["--allow-net", "main.ts"]
