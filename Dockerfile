# --------------> The builder image
FROM node:20.13.1 AS builder
ENV NODE_ENV=production
WORKDIR /home/node/app
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && npm install -g npm@10.8.0
ARG NPM_TOKEN
COPY package*.json ./
RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc && \
   npm ci --omit=dev && \
   rm -f .npmrc

# --------------> The production image
FROM node:20.13.1-slim AS production
ENV NODE_ENV=production
WORKDIR /home/node/app
COPY --from=builder /usr/bin/dumb-init /usr/bin/dumb-init
COPY --chown=node:node --from=builder /home/node/app/node_modules ./node_modules
COPY --chown=node:node . ./
USER node
CMD ["dumb-init", "node", "index.js"]
