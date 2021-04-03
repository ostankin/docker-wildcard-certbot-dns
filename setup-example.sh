#!/bin/bash

SSL_PROXY_DIR=./docker-compose/ssl_proxy
ENV_EXAMPLE="$SSL_PROXY_DIR/.env-example"
if [ ! -f "$ENV_EXAMPLE" ]; then
    >&2 echo "Can't find $ENV_EXAMPLE" 
    exit 1
fi

# Ask for the domain name and ports
source "$SSL_PROXY_DIR/.env-example"
read -p "Domain name [${DOMAIN_NAME}]: " input
DOMAIN_NAME="${input:-$DOMAIN_NAME}"
read -p "External HTTPS port [${EXTERNAL_HTTPS_PORT}]: " input
EXTERNAL_HTTPS_PORT="${input:-$EXTERNAL_HTTPS_PORT}"
read -p "External HTTP port [${EXTERNAL_HTTP_PORT}]: " input
EXTERNAL_HTTP_PORT="${input:-$EXTERNAL_HTTP_PORT}"
read -p "Certbot provider [${CERTBOT_PROVIDER}]: " input
CERTBOT_PROVIDER="${input:-$CERTBOT_PROVIDER}"

(
    cd "$SSL_PROXY_DIR"


    # Copy the config with example sites
    CONFIG_FILE=./config.yml
    if [ -f "$CONFIG_FILE" ]; then
        >&2 echo "$CONFIG_FILE already exists"
    fi 
    cp -i config-example.yml "$CONFIG_FILE"

    # Replace domain name in the example sites
    for i in 1 2; do
        sed -i -e "s!\(server_name\s*site${i}\.\)\(.*\);!\1$DOMAIN_NAME;!" \
            ../example-site$i/nginx.conf
    done

    echo 
)

# Generate .env file
ENV_FILE="$SSL_PROXY_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    >&2 echo "$ENV_FILE already exists"
    read -p "Type 'yes' to overwrite: " input
    if [ "$input" != "yes" ]; then
        exit 1;
    fi
fi
cat << EOF > "$ENV_FILE"
DOMAIN_NAME=$DOMAIN_NAME
EXTERNAL_HTTPS_PORT=$EXTERNAL_HTTPS_PORT
EXTERNAL_HTTP_PORT=$EXTERNAL_HTTP_PORT
CERTBOT_PROVIDER=$CERTBOT_PROVIDER
CONFIG_FILE=$CONFIG_FILE
CERTBOT_SECRET_FILE=$CERTBOT_SECRET_FILE
EOF

>&2 echo "NB! Make sure to provide your DNS provider credentials in $CERTBOT_SECRET_FILE!"
