FROM squidfunk/mkdocs-material

RUN apk add --no-cache --update nodejs npm bash hugo curl

WORKDIR /site
COPY ./package*.json /site/
COPY ./requirements.txt /site/

# Python Dependencies
RUN pip --no-cache-dir install -r requirements.txt
# NodeJS Dependencies
RUN npm ci
