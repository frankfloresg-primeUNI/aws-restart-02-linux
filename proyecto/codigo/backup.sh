#!/bin/bash
# Andes Tech - comprimir /empresa y subir a S3 con rol IAM de EC2
set -euo pipefail

if (( EUID != 0 )); then
  echo 'Ejecuta como root: sudo bash backup.sh' >&2
  exit 1
fi

command -v aws >/dev/null || { echo 'AWS CLI no esta instalado.' >&2; exit 1; }

# Archivo root-only con S3_BUCKET=nombre-del-bucket (no guardar claves aqui).
CONFIG='/etc/andes-tech-backup.conf'
if [[ -f "$CONFIG" ]]; then
  # Este archivo debe pertenecer a root y no ser editable por otros.
  # shellcheck disable=SC1090
  source "$CONFIG"
fi

BUCKET="${1:-${S3_BUCKET:-}}"
if [[ -z "$BUCKET" ]]; then
  echo 'Falta indicar el bucket: sudo bash backup.sh NOMBRE_BUCKET' >&2
  echo 'O configura S3_BUCKET en /etc/andes-tech-backup.conf.' >&2
  exit 1
fi

REGION="${AWS_REGION:-us-east-2}"
RESPALDOS='/var/backups/andes-tech'
mkdir -p "$RESPALDOS"
chmod 0700 "$RESPALDOS"
NOMBRE="empresa-$(date +%F_%H-%M-%S).tar.gz"
ARCHIVO="$RESPALDOS/$NOMBRE"

# Guardar fuera de /empresa evita que el backup se comprima a si mismo.
tar -czf "$ARCHIVO" -C / empresa
chmod 0600 "$ARCHIVO"

# AWS CLI obtiene credenciales temporales del rol IAM adjunto a EC2.
aws s3 cp "$ARCHIVO" "s3://$BUCKET/backups/$NOMBRE" --region "$REGION"
echo "Backup subido: s3://$BUCKET/backups/$NOMBRE"
