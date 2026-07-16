#!/bin/sh
set -eu

: "${HOST_ID:?HOST_ID is required}"
: "${WP_PRIMARY_URL:?WP_PRIMARY_URL is required}"
: "${WP_SECONDARY_URL:?WP_SECONDARY_URL is required}"
: "${REMOTE_WRITE_URL:?REMOTE_WRITE_URL is required}"

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

sed \
  -e "s|@@HOST_ID@@|$(escape_sed_replacement "$HOST_ID")|g" \
  -e "s|@@WP_PRIMARY_URL@@|$(escape_sed_replacement "$WP_PRIMARY_URL")|g" \
  -e "s|@@WP_SECONDARY_URL@@|$(escape_sed_replacement "$WP_SECONDARY_URL")|g" \
  -e "s|@@REMOTE_WRITE_URL@@|$(escape_sed_replacement "$REMOTE_WRITE_URL")|g" \
  /etc/prometheus/prometheus.agent.yml.tmpl > /tmp/prometheus-agent.yml

exec /bin/prometheus \
  --agent \
  --config.file=/tmp/prometheus-agent.yml \
  --storage.agent.path=/prometheus-agent \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle
