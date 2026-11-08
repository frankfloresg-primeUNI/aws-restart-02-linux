#!/bin/bash
# Andes Tech - Mision 8: provisionamiento idempotente (misiones 2 a 4)
set -euo pipefail

if (( EUID != 0 )); then
  echo 'Ejecuta este script como root: sudo bash setup-servidor.sh' >&2
  exit 1
fi

# Crear grupos solo si no existen.
for grupo in desarrollo finanzas; do
  getent group "$grupo" >/dev/null || groupadd "$grupo"
done

# Crear cuentas solo si faltan; conservar otros grupos de cuentas existentes.
usuarios_nuevos=()
asegurar_usuario() {
  local usuario="$1" grupo="$2"
  if ! id "$usuario" >/dev/null 2>&1; then
    useradd -m -G "$grupo" "$usuario"
    usuarios_nuevos+=("$usuario")
  else
    usermod -aG "$grupo" "$usuario"
  fi
}

asegurar_usuario ana desarrollo
asegurar_usuario luis desarrollo
asegurar_usuario carla finanzas
usermod -aG wheel ana

# La carpeta principal es atravesable; cada area privada solo por su grupo.
install -d -m 0755 /empresa
install -d /empresa/desarrollo /empresa/finanzas /empresa/publico
chown root:root /empresa
chmod 0755 /empresa

# Cambiar el grupo sin quitar a los propietarios de archivos ya existentes.
chgrp -R desarrollo /empresa/desarrollo
chgrp -R finanzas /empresa/finanzas
chown root:desarrollo /empresa/desarrollo
chown root:finanzas /empresa/finanzas

# Permisos: propietarios y miembros de grupo pueden trabajar, otros no.
chmod -R u+rwX,g+rwX,o-rwx /empresa/desarrollo /empresa/finanzas
# setgid en TODOS los subdirectorios, no solo en la carpeta principal.
find /empresa/desarrollo /empresa/finanzas -type d -exec chmod g+s {} +

# Area publica: solo ana es propietaria y puede escribir; otros solo leen.
chown -R ana:ana /empresa/publico
find /empresa/publico -type d -exec chmod 0755 {} +
find /empresa/publico -type f -exec chmod 0644 {} +

# No sobreescribir el archivo si ya existe.
if [[ ! -e /empresa/publico/LEEME.txt ]]; then
  cat > /empresa/publico/LEEME.txt <<'TEXTO'
REGLAS DE ANDES TECH
1. No compartir contrasenas.
2. Respetar las carpetas de cada departamento.
3. No eliminar archivos de otros usuarios.
4. Reportar incidencias al administrador.
TEXTO
  chown ana:ana /empresa/publico/LEEME.txt
  chmod 0644 /empresa/publico/LEEME.txt
fi

# Solo pedir contrasenas para cuentas NUEVAS si hay terminal interactiva.
# En user data no hay terminal: cuentas nuevas quedan bloqueadas hasta asignar passwd.
if (( ${#usuarios_nuevos[@]} > 0 )); then
  if [[ -t 0 ]]; then
    for usuario in "${usuarios_nuevos[@]}"; do
      echo "Establece una contrasena para la cuenta nueva: $usuario"
      passwd "$usuario"
    done
  else
    echo 'Cuentas nuevas creadas sin contrasena. Si las necesitas, ejecuta: sudo passwd ana|luis|carla individualmente.'
  fi
fi

echo 'Configuracion finalizada. Puedes volver a ejecutar este script.'
getent group desarrollo finanzas
id ana
id luis
id carla
ls -ld /empresa /empresa/*
