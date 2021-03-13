ssl_certificate     ${SSL_DIR}/${SSL_DOMAIN}/fullchain.pem;
ssl_certificate_key ${SSL_DIR}/${SSL_DOMAIN}/privkey.pem;
ssl_protocols TLSv1.3 TLSv1.2;
ssl_ecdh_curve secp521r1:secp384r1;
ssl_ciphers EECDH+AESGCM:EECDH+AES256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:!ECDHE-RSA-AES256-SHA384:!ECDHE-RSA-AES256-SHA;
ssl_session_cache  builtin:1000  shared:SSL:10m;
ssl_buffer_size 4k;
ssl_dhparam /etc/nginx/dhparam.pem;
ssl_prefer_server_ciphers on;
