FROM nginx:alpine

COPY dhparam.pem /etc/nginx
RUN mkdir /src
RUN (export YQ_VERSION=4.6.1 \
  && export YQ_ARCH=$(apk --print-arch | \
  sed -e 's;^x86$;386;' -e 's;^x86_64$;amd64;' -e 's;^arm7$;arm;' -e 's;^armhf$;arm;' -e 's;^aarch64$;arm64;') \
  && wget "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${YQ_ARCH}" -O /usr/bin/yq \
  && chmod +x /usr/bin/yq)
COPY ssl.conf.tpl /src
COPY upstream.conf.tpl /src
COPY default.conf /src
COPY check /check
COPY start /start
ENTRYPOINT [ "/start" ]
CMD ["nginx", "-g", "daemon off;"]