FROM alpine:3.7

LABEL description "Next-generation forum software that makes online discussion fun" \
      maintainer="Hardware <hardware@mondedie.fr>, Magicalex <magicalex@mondedie.fr>"

ARG VERSION=v0.1.0-beta.7

ENV GID=991 \
    UID=991 \
    UPLOAD_MAX_SIZE=50M \
    PHP_MEMORY_LIMIT=128M \
    OPCACHE_MEMORY_LIMIT=128 \
    FORUM_URL=localhost \
    DB_HOST=localhost \
    DB_PASS=password

RUN echo "@community https://nl.alpinelinux.org/alpine/v3.7/community" >> /etc/apk/repositories \
 && apk add -U \
    nginx \
    s6 \
    su-exec \
    curl \
    php7@community \
    php7-fileinfo@community \
    php7-phar@community \
    php7-fpm@community \
    php7-curl@community \
    php7-mbstring@community \
    php7-openssl@community \
    php7-json@community \
    php7-pdo@community \
    php7-pdo_mysql@community \
    php7-mysqlnd@community \
    php7-zlib@community \
    php7-gd@community \
    php7-dom@community \
    php7-ctype@community \
    php7-session@community \
    php7-opcache@community \
    php7-xmlwriter@community \
    php7-tokenizer@community \
 && cd /tmp \
 && curl -s http://getcomposer.org/installer | php \
 && mv /tmp/composer.phar /usr/bin/composer \
 && chmod +x /usr/bin/composer \
 && mkdir -p /flarum/app \
 && chown -R $UID:$GID /flarum \
 && COMPOSER_CACHE_DIR="/tmp" su-exec $UID:$GID composer create-project flarum/flarum /flarum/app $VERSION --stability=beta \
 && composer require jsthon/flarum-ext-simplified-chinese $VERSION \
 && composer clear-cache \
 && rm -rf /flarum/.composer /var/cache/apk/*

COPY rootfs /
RUN chmod +x /usr/local/bin/* /services/*/run /services/.s6-svscan/*
VOLUME /flarum/app/assets /flarum/app/extensions
EXPOSE 8888
CMD ["run.sh"]
