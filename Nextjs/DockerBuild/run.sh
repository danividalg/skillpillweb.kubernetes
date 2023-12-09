#!/bin/sh

cd /app

export CERT_DIR=$(openssl version -d | cut -f2 -d \")
export CERT_DIR=$CERT_DIR/certs
cp /app/ca.cert.crt $CERT_DIR
update-ca-certificates

openssl dhparam -dsaparam -out /etc/ssl/certs/dhparam.pem 2048
nginx

su nextjs -c /app/run_node.sh
