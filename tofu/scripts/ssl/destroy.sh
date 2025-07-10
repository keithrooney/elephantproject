#!/bin/bash
DEFAULT_OPENSSL_OUTPUT_DIRECTORY="$HOME/.elephantproject/ssl"
for name in "server.key" "server.crt" "server.csr";
do 
    rm "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/$name"
done
