ARG ALPINE_VERSION=3.17
ARG PHP_VERSION=82
ARG BUILD_ENV=production
ARG DEBUG_PACKAGES="nano bash net-tools wget"
ARG INCLUDE_COMPOSER=true
FROM alpine:${ALPINE_VERSION}

LABEL Maintainer="Höglandets IT"
LABEL Description="Lightweight PHP-FPM and Nginx container based on Alpine Linux."
LABEL Version="1.0"

# # If debug is enabled, install the debug packages
ARG BUILD_ENV
ARG DEBUG_PACKAGES
RUN echo "Install debug packages: ${BUILD_ENV}" && if [ ${BUILD_ENV} = "debug" ]; then apk add --no-cache ${DEBUG_PACKAGES}; fi

# Set the working directory to /app and install application packages
WORKDIR /app
RUN mkdir -p /app/public

ADD configs/apk.conf /etc/apk/repositories
RUN apk update

ARG PHP_VERSION
RUN apk update && apk add --no-cache \
    curl nginx supervisor msmtp curl git \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-session \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xmlreader \
    php${PHP_VERSION}-xmlwriter \
    php${PHP_VERSION}-sqlite3


# Add Supervisor, Nginx and FPM Configurations
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/fpmpool.conf /etc/php${PHP_VERSION}/php-fpm.conf
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add sample index file for verification
COPY configs/index.php /app/index.php

# Ensure the files and folders needed by the processes are accessible to a normal user
# and that the supervisord file has the correct PHP version. Also link php to php[version]
# for apps that require it (like composer)
ARG PHP_VERSION
RUN chown -R nobody.nobody /app /run /var/www /var/lib/nginx /var/log/nginx /var/log/php${PHP_VERSION} \
    && sed -i "s/PHP_VERSION/${PHP_VERSION}/g" /etc/supervisor/conf.d/supervisord.conf && \
    ln -sf /usr/bin/php${PHP_VERSION} /usr/bin/php

# Add composer if enabled
ARG INCLUDE_COMPOSER
RUN echo "Install Composer: ${INCLUDE_COMPOSER}" && if [ ${INCLUDE_COMPOSER} = "true" ]; then \
        curl -sS https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer; \
    fi

# Switch to a non-root user
USER nobody

# Expose the listening port of nginx
EXPOSE 8080

# Run the supervisor to start the services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Setup the healthchecks to ensure the container is health and responding
HEALTHCHECK --interval=5s --timeout=5s --start-period=15s --retries=3 CMD curl -sf http://127.0.0.1:8080/fpm-ping || exit 1

ENV APPLICATION_PATH=/app \
    WEBROOT_FOLDER=public \
    PHP_ADDITIONAL_PACKAGES="" \
    PHP_ADDITIONAL_OPTIONS="" \
    NGINX_WORKER_CONNECTIONS=1024 \
    NGINX_CUSTOM_5XX_ERROR_PAGE="" \
    INIT_COMMANDS=""
