# The builder image
FROM node:23.9.0 AS builder
ENV NODE_ENV=production
WORKDIR /home/node/app
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=secret,id=npmrc,target=/home/node/.npmrc \
    apt-get update && \
    apt-get install -y --no-install-recommends dumb-init && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    npm ci --omit=dev

# The production image
FROM node:23.9.0-slim AS production
ENV NODE_ENV=production
WORKDIR /home/node/app
COPY --from=builder /usr/bin/dumb-init /usr/bin/dumb-init
COPY --chown=node:node --from=builder /home/node/app/node_modules ./node_modules
COPY --chown=node:node . ./
USER node
CMD ["dumb-init", "node", "index.js"]
