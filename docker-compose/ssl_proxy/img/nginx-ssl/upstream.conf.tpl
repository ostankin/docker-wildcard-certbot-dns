server {
    listen       80;
    server_name  ${UPSTREAM_SUBDOMAIN}.${SSL_DOMAIN};
    return 301 https://$host$request_uri;
}

server {
    include /etc/nginx/conf.d/ssl.conf;
    listen       443 ssl;
    server_name  ${UPSTREAM_SUBDOMAIN}.${SSL_DOMAIN};

    charset UTF-8;
    access_log  /var/log/nginx/access.log  main;

    location / {
      proxy_pass ${UPSTREAM_URL};
      proxy_set_header Host      ${DOLLAR_SIGN}host;
      proxy_set_header X-Forwarded-For ${DOLLAR_SIGN}remote_addr;
    }
}