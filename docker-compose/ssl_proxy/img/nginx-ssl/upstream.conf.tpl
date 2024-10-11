server {
    listen       80;
    server_name  ${UPSTREAM_SUBDOMAIN}.${SSL_DOMAIN};
    return 301 https://${DOLLAR_SIGN}host${DOLLAR_SIGN}request_uri;
}

server {
    include /etc/nginx/conf.d/ssl.conf;
${UPSTREAM_INCLUDE}
    listen       443 ssl;
    server_name  ${UPSTREAM_SUBDOMAIN}.${SSL_DOMAIN};

    charset UTF-8;
    access_log  /var/log/nginx/access.log  main;

    location / {
      proxy_pass ${UPSTREAM_URL};
      proxy_set_header Host      ${DOLLAR_SIGN}host;
      proxy_set_header X-Forwarded-For ${DOLLAR_SIGN}remote_addr;
      proxy_set_header X-Forwarded-Proto ${DOLLAR_SIGN}scheme;
      proxy_set_header X-Forwarded-Host ${DOLLAR_SIGN}host:${DOLLAR_SIGN}server_port;
      proxy_set_header X-Forwarded-Port ${DOLLAR_SIGN}server_port;
      proxy_redirect off;

      proxy_http_version 1.1;
      proxy_set_header Upgrade ${DOLLAR_SIGN}http_upgrade;
      proxy_set_header Connection ${DOLLAR_SIGN}connection_upgrade;
    }
}
