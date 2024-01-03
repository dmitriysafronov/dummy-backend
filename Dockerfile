# --------------> The build image
FROM node:20.10.0 AS build
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init
ARG NPM_TOKEN
WORKDIR /usr/src/app
COPY package*.json /usr/src/app/
RUN echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" > .npmrc && \
   npm ci --omit=dev && \
   rm -f .npmrc
 
# --------------> The production image
FROM node:20.10.0-slim
ENV NODE_ENV production
COPY --from=build /usr/bin/dumb-init /usr/bin/dumb-init
USER node
WORKDIR /usr/src/app
COPY --chown=node:node --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --chown=node:node . /usr/src/app
CMD ["dumb-init", "node", "index.js"]
