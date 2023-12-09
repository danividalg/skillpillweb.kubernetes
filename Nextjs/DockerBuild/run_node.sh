#!/bin/sh

cd /app

export PORT=3000
export HOSTNAME="0.0.0.0"
export NODE_OPTIONS=--use-openssl-ca
export NEXT_SHARP_PATH=/app/node_modules/sharp
export NEXT_TELEMETRY_DISABLED=1
export NODE_ENV=production

node /app/server.js
