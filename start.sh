#!/bin/bash
set -e
export SCANNER_TRIVY_INSECURE=true
if test -z "$http_proxy"; then
	echo "please set http_proxy"
	exit 1
fi
if test -z "$https_proxy"; then
	echo "please set https_proxy"
	exit 1
fi
redis-server /etc/redis.conf && echo "redis start..."
scanner-trivy
