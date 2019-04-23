#!/bin/bash

# Specify where we will install
# the placeholder.local certificate
SSL_DIR="/etc/nginx/ssl"

# Set the domain
# we want to use
DOMAIN="placeholder.local"

# A blank passphrase
PASSPHRASE=""

# Set our CSR variables
SUBJ="
C=US
ST=MINNESOTA
L=MINNEAPOLIS
O=NIIKNOW
EMAIL=somebody@somewhere.com
CN=$DOMAIN
"

# Create our SSL directory
# in case it doesn't exist
mkdir -p "$SSL_DIR"

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$SSL_DIR/placeholder-privkey.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/placeholder-privkey.key" -out "$SSL_DIR/placeholder.csr" -passin pass:$PASSPHRASE
openssl x509 -req -days 3650 -in "$SSL_DIR/placeholder.csr" -signkey "$SSL_DIR/placeholder-privkey.key" -out "$SSL_DIR/placeholder-fullchain.crt"
