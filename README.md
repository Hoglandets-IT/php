# Docker image for Nginx/PHP-FPM

## Build Args
| Name | Description | Default |
| --- | --- | --- |
| ALPINE_VERSION | Alpine version to use | 3.16 |
| INCLUDE_COMPOSER | Whether to include Composer in the image | true |
| PHP_VERSION | PHP version to install (alpine naming standard, e.g. php8, php74) | 8 |
| BUILD_ENV | Whether to build the container with debug software installed () (debug, production) | production |
| DEBUG_PACKAGES | Packages to install in debug environment | nano bash net-tools wget git openssh-client rsync unzip |

## Environment Variables (Nginx)
| Name | Description | Example | Default |
| --- | --- | --- |
| APPLICATION_PATH | The path to the location of the application (in-container path) | /var/www/html | /app/public |
| WEBROOT_FOLDER | If you have a subfolder in the app folder that is used for the webroot, set it here | public | "public" |
| NGINX_WORKER_CONNECTIONS | Number of connections to allow per worker | 512 | 1024 |
| NGINX_CUSTOM_5XX_ERROR_PAGE | Path to custom 5xx error page (in-container) | /app/500-error.html | /var/lib/nginx/html/5xx.html |
| NGINX_SRVCFG_xx_xx | Set Nginx options in the server block. Case-insensitive | NGINX_SRVCFG_CLIENT_MAX_BODY_SIZE=10m | "" |
 

## Environment Variables (PHP)
| Name | Description | Example | Default |
| --- | --- | --- |
| PHPVAL_xx_xx | Set PHP values (e.g. PHPVAL_MAX_EXECUTION_TIME=60). Case insensitive | PHPVAL_MAX_EXECUTION_TIME=60 | "" |
| PHP_ADDITIONAL_PACKAGES | Additional PHP packages to install | "sqlite3,pdo,mysql" | "" |
|