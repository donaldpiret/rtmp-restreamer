#!/usr/bin/env sh
set -e

/bin/render_template.rb /opt/nginx/nginx.conf.erb /opt/nginx/nginx.conf

exec "$@"
