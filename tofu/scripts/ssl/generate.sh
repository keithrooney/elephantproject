#!/bin/bash
DEFAULT_OPENSSL_OUTPUT_DIRECTORY="$HOME/.elephantproject/ssl"
DEFAULT_OPENSSL_CONFIG_PATH="$HOME/.elephantproject/ssl/openssl.cnf"

config_path=$DEFAULT_OPENSSL_CONFIG_PATH

fail() {
    echo "error: $1"
    exit 1
}

while [ $# -gt 0 ]; do
  case $1 in
    -c|--config)
        config_path="$2"
        shift
        shift
        ;;
    *)
        fail "Usage: sh generate.sh [-c config_path]"
        ;;
  esac
done

if [ ! -f $config_path ];
then
    fail "config path [$config_path] does not exist"
fi

# generate the server private key
openssl genrsa -out "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/server.key" 4096 ;

# generate the client signing request
openssl req -new -key "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/server.key" -out "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/server.csr" -config $config_path ;

# generate the self signed server certificate
openssl x509 -req -in "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/server.csr" -signkey "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/server.key" -out "$DEFAULT_OPENSSL_OUTPUT_DIRECTORY/server.crt" -days 365 -extensions req_ext -extfile $config_path ;
