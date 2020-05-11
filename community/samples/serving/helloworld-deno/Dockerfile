FROM hayd/alpine-deno:0.38.0
EXPOSE 8080
WORKDIR /app
# Prefer not to run as root.
USER deno

# Cache the dependencies as a layer (the following two steps are re-run only when deps.ts is modified).
COPY deps.ts .
RUN deno fetch deps.ts

# These steps will be re-run upon each file change in your working directory:
ADD . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno fetch main.ts

# Added to ENTRYPOINT of base image.
CMD ["--allow-net", "main.ts"]
