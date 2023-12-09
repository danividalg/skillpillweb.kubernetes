FROM node:20.10-alpine AS base


FROM base AS builder

RUN apk update
RUN apk add --no-cache musl libc6-compat make gcc g++ python3
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED 1
ENV NEXT_SHARP_PATH /app/.next/standalone/node_modules/sharp

COPY . .

RUN npm ci
RUN npm install --save-dev @types/node @types/react-dom eslint
RUN npm install --save --cpu=arm64 --arch=arm64 --os=linux --platform=linux --libc=musl node-addon-api node-gyp @types/node @types/react-dom eslint
RUN npm install --save --cpu=arm64 --arch=arm64 --os=linux --platform=linux --libc=musl --build-from-source sharp

RUN npm run lint
RUN npm run build


# Sharp
FROM base AS sharp
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED 1
ENV NEXT_SHARP_PATH /app/node_modules/sharp
ENV NODE_ENV production

# Re-install Sharp
RUN apk update
RUN apk add --no-cache musl libc6-compat make gcc g++ python3
RUN npm install --save --cpu=arm64 --arch=arm64 --os=linux --platform=linux --libc=musl sharp


# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED 1
ENV NEXT_SHARP_PATH /app/node_modules/sharp
ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system -s /bin/sh --uid 1001 nextjs

#Copy web app, static, public and sharp
COPY --from=sharp --chown=nextjs:nodejs /app /app
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone /app
COPY --from=builder --chown=nextjs:nodejs /app/.next/static /app/.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public /app/public
COPY --from=sharp --chown=nextjs:nodejs /app/node_modules/sharp /app/node_modules/sharp

# Run scripts
COPY --chown=nextjs:nodejs run.sh /app/run.sh
COPY --chown=nextjs:nodejs run_node.sh /app/run_node.sh

# Set the correct permission for prerender cache
RUN chown -R nextjs:nodejs /app
RUN chmod 774 /app/run.sh
RUN chmod 774 /app/run_node.sh

# Add backend certificate to trusted
RUN apk update
RUN apk add --no-cache ca-certificates openssl nginx

# Nginx
COPY --chown=root:root nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=root:root nginx/default.conf /etc/nginx/http.d/default.conf
COPY --chown=root:root nginx/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

# For local docker tests, comment for production
#COPY --chown=nextjs:nodejs nginx/frontend-server.key.pem /app/
#COPY --chown=nextjs:nodejs nginx/frontend-server-fullchain.cert.pem /app/
#COPY --chown=nextjs:nodejs nginx/ca.cert.crt /app/
#COPY --chown=nextjs:nodejs nginx/.env /app/

#Next.js
EXPOSE 80
EXPOSE 443

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
ENTRYPOINT ["/bin/sh"]
CMD ["-c", "/app/run.sh"]
