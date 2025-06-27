#!/bin/bash
OUTPUT_DIRECTORY="$HOME/.elephantproject/ssl"

# generate the server private key
openssl genrsa -out "$OUTPUT_DIRECTORY/server.key" 4096 ;

# generate the client signing request
openssl req -new -key "$OUTPUT_DIRECTORY/server.key" -out "$OUTPUT_DIRECTORY/server.csr" -config openssl.cnf ;

# generate the self signed server certificate
openssl x509 -req -in "$OUTPUT_DIRECTORY/server.csr" -signkey "$OUTPUT_DIRECTORY/server.key" -out "$OUTPUT_DIRECTORY/server.crt" -days 365 -extensions req_ext -extfile openssl.cnf ;
