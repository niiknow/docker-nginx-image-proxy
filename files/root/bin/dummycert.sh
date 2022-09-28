#!/bin/bash
# Specify where we will install
# the dummycert certificate
SSL_DIR="/etc/nginx/ssl"

# Create our SSL directory
# in case it doesn't exist
mkdir -p "$SSL_DIR"

# Generate dummy self-signed certificate.
if [ ! -f $SSL_DIR/dummycert.pem ] || [ ! -f $SSL_DIR/dummykey.pem ]
then
	echo "Generating dummy SSL certificate..."
	openssl req \
		-new \
		-newkey rsa:2048 \
		-days 3650 \
		-nodes \
		-x509 \
		-subj '/O=localhost/OU=localhost/CN=localhost' \
		-keyout $SSL_DIR/dummykey.pem \
		-out $SSL_DIR/dummycert.pem
	echo "Complete"
fi
