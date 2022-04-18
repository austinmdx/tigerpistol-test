# Install dependencies only when needed

ARG REGISTRY_TOKEN
ARG FONTAWESOME_TOKEN

FROM node:16-alpine AS deps

ARG REGISTRY_TOKEN
ARG FONTAWESOME_TOKEN

ENV FONTAWESOME_TOKEN $FONTAWESOME_TOKEN
ENV REGISTRY_TOKEN $REGISTRY_TOKEN
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
RUN echo "========== First Workdir =========="
RUN ls -a
COPY package.json ./

RUN echo //npm.pkg.github.com/:_authToken=$REGISTRY_TOKEN >> ~/.npmrc
RUN echo @credasinc:registry=https://npm.pkg.github.com/ >> ~/.npmrc
RUN echo //npm.fontawesome.com/:_authToken=$FONTAWESOME_TOKEN >> ~/.npmrc
RUN echo @fortawesome:registry=https://npm.fontawesome.com/ >> ~/.npmrc

# RUN npm install
COPY package.json package-lock.json ./ 
RUN npm ci
RUN echo '==== after npm ci ====='
RUN ls -a
# COPY package.json package-lock.json ./ 
# RUN npm ci --only=production --ignore-scripts

RUN echo > ~/.npmrc

# If using npm with a `package-lock.json` comment out above and use below instead
# COPY package.json package-lock.json ./ 
# RUN npm ci

# Rebuild the source code only when needed
FROM node:16-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN echo '==== Showing all dir ====='
RUN ls -a

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
# ENV NEXT_TELEMETRY_DISABLED 1

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]