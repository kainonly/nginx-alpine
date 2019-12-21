FROM alpine:edge as development

ENV NGINX_VERSION 1.17.6

RUN apk add --no-cache \
    git \
    && mkdir -p /src \
    && cd /src \
    && git clone --recursive https://github.com/google/ngx_brotli.git

RUN apk add --no-cache --virtual .build-deps \
    linux-headers \
    gcc \
    g++ \
    make \
    cmake \
    autoconf \
    automake \
    zlib-dev \
    pcre-dev \
    openssl-dev \
    gnupg \
    curl \
    && curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz \
    && curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc -o nginx.tar.gz.asc \
    && gpg --keyserver hkp://pgp.key-server.io --recv-keys 520A9993A1C052F8 \
    && gpg --verify nginx.tar.gz.asc \
    && tar -xvzf nginx.tar.gz -C /src \
    && cd /src/nginx-${NGINX_VERSION} \
    && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-Os -fomit-frame-pointer' \
    --with-ld-opt=-Wl,--as-needed \
    --add-module=/src/ngx_brotli \
    && make && make install \
    && mkdir -p /etc/nginx/vhost \
    && rm -rf /etc/nginx/html /src /nginx.tar.gz /nginx.tar.gz.asc \
    && apk del .build-deps

FROM alpine:3.10

COPY --from=development /etc/nginx /etc/nginx
COPY --from=development /usr/sbin/nginx /usr/sbin/nginx

RUN apk --no-cache add \
    libgcc \
    pcre \
    tzdata \
    && addgroup -g 82 -S nginx \
    && adduser -S -D -H -u 82 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && mkdir -p /var/cache/nginx \
    && chown -R nginx:nginx /var/cache/nginx \
    && mkdir -p /var/log/nginx \
    && chown -R nginx:nginx /var/log/nginx

EXPOSE 80 443
STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]