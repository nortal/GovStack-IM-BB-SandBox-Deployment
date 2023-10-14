#!/bin/bash
_log() { echo "$(date --utc -Iseconds) INFO [entrypoint] $*"; }
_warn() { echo "$(date --utc -Iseconds) WARN [entrypoint] $*" >&2; }

_log "Waiting for database ${XROAD_DB_HOST}..."
wait_for_db() {
  local count=0
  local max=$1
  while ((count++ < $max)) && ! pg_isready -h "$XROAD_DB_HOST" -p "$XROAD_DB_PORT"; do
    sleep 10
  done
  if ((count>=$max)); then
    _warn "Unable to determine database status in $count retries"
  else
    _log "Database available, continuing..."
  fi
}
wait_for_db 60

LOCAL_DB=false
XROAD_ADMIN_USER=${XROAD_ADMIN_USER:-xrd}
XROAD_ADMIN_PASSWORD=${XROAD_ADMIN_PASSWORD:-secret}
export LIQUIBASE_SHOW_BANNER=false

source ./root/_entrypoint_common.sh

# restore backup if there is one
if [[ -f /var/lib/xroad/conf_backup.tar && ! -f /etc/xroad/.initialized ]]; then
  log "Applying configuration..."
  tar -C / -xf /var/lib/xroad/conf_backup.tar etc/xroad/configuration-anchor.xml etc/xroad/globalconf etc/xroad/signer var/lib/xroad/dbdump.dat
  chown -R xroad:xroad /etc/xroad/globalconf /etc/xroad/configuration-anchor.xml /etc/xroad/signer /var/lib/xroad/dbdump.dat
  /usr/share/xroad/scripts/restore_db.sh /var/lib/xroad/dbdump.dat 2>&1 | sed 's/^/    /'
  dpkg-reconfigure xroad-proxy
  touch /etc/xroad/.initialized
  chown xroad:xroad /etc/xroad/.initialized
fi

if [[ -n "${XROAD_PROXY_UI_API_PARAMS}" ]]; then
    echo "XROAD_PROXY_UI_API_PARAMS=${XROAD_PROXY_UI_API_PARAMS}" >> /etc/xroad/services/local.properties
fi

# Start services
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
