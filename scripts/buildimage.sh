#!/usr/bin/bash
IMAGE=$1

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <image>"
    echo "Available Images:\r\n"
    echo -e "php82\r\nphp81\r\nphp8\r\nphp7\r\nphp82-debug\r\nphp81-debug\r\nphp8-debug\r\nphp7-debug"
    exit 1
fi

docker-compose -f docker-compose.build.yml build $IMAGE