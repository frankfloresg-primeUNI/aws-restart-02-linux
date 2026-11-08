#!/bin/bash
# Andes Tech - reporte diario del servidor
set -euo pipefail

if (( EUID != 0 )); then
  echo 'Ejecuta como root: sudo bash reporte.sh' >&2
  exit 1
fi

export LC_ALL=C
DESTINO='/empresa/publico/reportes'
install -d -m 0755 "$DESTINO"
chown ana:ana "$DESTINO"
ARCHIVO="$DESTINO/reporte-$(date +%F).txt"
TMP="$(mktemp "$DESTINO/.reporte.XXXXXXXX")"
trap 'rm -f "$TMP"' EXIT

{
  echo 'REPORTE DE ANDES TECH'
  echo "Fecha y hora: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "Servidor: $(hostname)"
  echo
  echo '=== UPTIME ==='
  uptime -p
  echo
  echo '=== DISCO ==='
  df -h /empresa
  echo
  echo '=== MEMORIA ==='
  free -h
  echo
  echo '=== 5 PROCESOS QUE MAS MEMORIA UTILIZAN ==='
  ps -eo pid,user,comm,%mem,%cpu --sort=-%mem | sed -n '1,6p'
  echo
  echo '=== SERVICIO APACHE ==='
  echo "Activo: $(systemctl is-active httpd 2>/dev/null || true)"
  echo "Inicio automatico: $(systemctl is-enabled httpd 2>/dev/null || true)"
  echo
  echo '=== IPs CON MAS SOLICITUDES HTTP (HASTA 5) ==='
  if [[ -r /var/log/httpd/access_log ]]; then
    awk '{visitas[$1]++} END {for (ip in visitas) print visitas[ip],ip}' /var/log/httpd/access_log \
      | sort -nr | sed -n '1,5p'
  else
    echo 'No existe un access_log legible.'
  fi
} > "$TMP"

chown ana:ana "$TMP"
chmod 0644 "$TMP"
mv -f "$TMP" "$ARCHIVO"
trap - EXIT
echo "Reporte generado: $ARCHIVO"
