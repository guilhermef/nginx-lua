FROM debian:jessie-slim

ENV NGINX_VERSION 1.12.2
ENV LUA_NGINX_MODULE_VERSION 0.10.11

RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    libpcre3-dev \
    libssl-dev \
    libluajit-5.1-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev && \
    cd /tmp && \
    wget https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz && tar zxvf v${LUA_NGINX_MODULE_VERSION}.tar.gz && \
    wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    LUAJIT_LIB=/usr/lib \
    LUAJIT_INC=/usr/include/luajit-2.0 \
    ./configure \
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
      --user=www-data \
      --group=www-data \
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
      --add-module=/tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} \
      --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
      --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' && \
    make && \
    make install && \
    rm -rf /tmp/v${LUA_NGINX_MODULE_VERSION}.tar.gz /tmp/nginx-${NGINX_VERSION}.tar.gz /tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} /tmp/nginx-${NGINX_VERSION} && \
    cd /etc/nginx && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      luarocks \
      unzip \
      git \
      openssl && \
    luarocks install lbase64 && \
    luarocks install lua-resty-http && \
    luarocks install lua-resty-string && \
    luarocks install lua-resty-hmac && \
    luarocks install lua-resty-jwt && \
    luarocks install lua-cjson && \
    luarocks install lunajson && \
    luarocks install split && \
    apt-get -y purge \
      wget \
      unzip \
      git \
      build-essential && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/cache/nginx/client_temp && \
    chown www-data:www-data /var/cache/nginx/client_temp

COPY system/nginx /etc/init.d/nginx
RUN chmod +x /etc/init.d/nginx
COPY system/default_nginx /etc/default/nginx
COPY system/nginx.service /etc/systemd/system/nginx.service
RUN systemctl enable nginx.service

CMD ["nginx"]
