ARG NGINX_VERSION=1.15.1
ARG NGINX_RTMP_VERSION=1.2.1

##############################
# Build the NGINX-build image.
FROM alpine:latest as build-nginx
ARG NGINX_VERSION
ARG NGINX_RTMP_VERSION

# Build dependencies.
RUN apk add --update \
  build-base \
  ca-certificates \
  curl \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev

# Get nginx source.
RUN cd /tmp && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz && \
  tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-${NGINX_VERSION} && \
  ./configure \
  --prefix=/opt/nginx \
  --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --conf-path=/opt/nginx/nginx.conf \
  --with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --error-log-path=/opt/nginx/logs/error.log \
  --http-log-path=/opt/nginx/logs/access.log \
  --with-debug && \
  cd /tmp/nginx-${NGINX_VERSION} && make && make install

##########################
# Build the release image.
FROM alpine:latest

LABEL MAINTAINER="Donald Piret <me@donald.sg>"

ENV RTMP_PUBLISH_KEY="secret"
ENV RTMP_FORWARDING_URLS=""

RUN apk add --update \
  ca-certificates \
  openssl \
  pcre \
  lame \
  libogg \
  libass \
  libvpx \
  libvorbis \
  libwebp \
  libtheora \
  opus \
  rtmpdump \
  x264-dev \
  x265-dev \
  ruby \
  ruby-bundler

COPY --from=build-nginx /opt/nginx /opt/nginx

# Add NGINX config and static files.
ADD bin/entrypoint.sh /bin/entrypoint.sh
ADD bin/render_template.rb /bin/render_template.rb
ADD templates/nginx.conf.erb /opt/nginx/nginx.conf.erb
RUN mkdir -p /opt/data && mkdir /www

# Forward logs to Docker
RUN ln -sf /dev/stdout /opt/nginx/logs/access.log && \
    ln -sf /dev/stderr /opt/nginx/logs/error.log

EXPOSE 1935
# EXPOSE 80

ENTRYPOINT ["/bin/entrypoint.sh"]

CMD ["/opt/nginx/sbin/nginx"]