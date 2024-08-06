# VERSIONS
ARG NODE_VERSION=20.13.1
ARG NPM_VERSION=10.8.0

# --------------> The builder image
FROM node:$NODE_VERSION AS builder
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
ARG NPM_TOKEN
COPY package*.json /usr/src/app/
RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc && \
   npm install -g npm@$NPM_VERSION && \
   npm ci --omit=dev && \
   rm -f .npmrc

# --------------> The production image
FROM node:$NODE_VERSION-slim AS production
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY --from=builder /usr/bin/dumb-init /usr/bin/dumb-init
COPY --chown=node:node --from=builder /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
USER node
CMD ["dumb-init", "node", "index.js"]
