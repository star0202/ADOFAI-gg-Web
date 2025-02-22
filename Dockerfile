FROM node:18-alpine AS builder

RUN mkdir -p /app

WORKDIR /app

COPY package.json .yarnrc.yml yarn.lock ./

COPY .yarn .yarn

RUN corepack enable && yarn --frozen-lockfile

COPY . .

ARG API_ENDPOINT
ARG OPENGRAPH_ENDPOINT
ARG DISCORD_INVITE
ARG SUPPORT_MAIL

RUN VITE_API_ENDPOINT=${API_ENDPOINT} VITE_OPENGRAPH_ENDPOINT=${OPENGRAPH_ENDPOINT} VITE_DISCORD_INVITE=${DISCORD_INVITE} VITE_SUPPORT_MAIL=${SUPPORT_MAIL} yarn build

RUN apk add jq

RUN cat package.json | jq 'del(.devDependencies) | del(.resolutions) | del(.scripts)' | tee package.json

RUN yarn pack

FROM node:18-alpine AS runner

COPY --from=builder /app/package.tgz .

RUN tar xvzf package.tgz && \
    rm package.tgz && \
    mv package app && \
    cd app && \
    corepack enable && \
    yarn

WORKDIR /app

CMD ["yarn", "node", "server.js"]
