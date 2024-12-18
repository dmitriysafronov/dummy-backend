# --------------> The builder image
FROM node:20.13.1 AS builder
ENV NODE_ENV=production
WORKDIR /usr/src/app
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
ARG NPM_TOKEN
COPY package*.json /usr/src/app/
RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc && \
   npm install -g npm@$10.8.0 && \
   npm ci --omit=dev && \
   rm -f .npmrc

# --------------> The production image
FROM node:20.13.1-slim AS production
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY --from=builder /usr/bin/dumb-init /usr/bin/dumb-init
COPY --chown=node:node --from=builder /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
USER node
CMD ["dumb-init", "node", "index.js"]
