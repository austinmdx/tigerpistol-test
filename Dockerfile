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
RUN ls
COPY package.json ./
#RUN yarn install --frozen-lockfile
COPY .env.local ./

RUN cat .env.local

RUN echo //npm.pkg.github.com/:_authToken=$REGISTRY_TOKEN >> ~/.npmrc
RUN echo @credasinc:registry=https://npm.pkg.github.com/ >> ~/.npmrc
RUN echo //npm.fontawesome.com/:_authToken=$FONTAWESOME_TOKEN >> ~/.npmrc
RUN echo @fortawesome:registry=https://npm.fontawesome.com/ >> ~/.npmrc

# RUN npm install
COPY package.json package-lock.json ./ 
RUN npm ci
# COPY package.json package-lock.json ./ 
# RUN npm ci --only=production --ignore-scripts

RUN echo > ~/.npmrc

# If using npm with a `package-lock.json` comment out above and use below instead
# COPY package.json package-lock.json ./ 
# RUN npm ci

# Rebuild the source code only when needed
FROM node:16-alpine AS builder
WORKDIR /app
RUN ls
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN cat .env.local

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
# ENV NEXT_TELEMETRY_DISABLED 1

#RUN yarn build
RUN npx prisma generate
RUN npm run build

# Production image, copy all the files and run next
FROM node:16-alpine AS runner
WORKDIR /app
COPY .env.local ./

ENV NODE_ENV production
# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# You only need to copy next.config.js if you are NOT using the default configuration
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Automatically leverage output traces to reduce image size 
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]