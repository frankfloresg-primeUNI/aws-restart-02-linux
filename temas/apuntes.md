**02/11/2026**

1.- Se configuró SSH solo desde mi IP y no desde 0.0.0.0/0, para reducir la exposición a intentos de acceso no deseados. Aún así, ello no remplazo la autenticación mediante nuestra clase .pem

icacls permite modificar permisos de archivos en Windows. Utilizamos /inheritance:r para eliminar permisos heredados de nuestra clave privada .pem, y /grant:r "${env:USERNAME}:R" para conceder permiso de lectura a nuestro usuario. De esta manera protegemos la clave y evitamos que SSH la rechace por tener permisos demasiado abiertos.

2.-

| Directorio | ¿Para qué sirve?                                |
| ---------- | ------------------------------------------------- |
| `/etc`   | Guarda archivos de configuración del sistema.    |
| `/var`   | Guarda datos variables, como logs y cachés.      |
| `/home`  | Contiene las carpetas personales de los usuarios. |
| `/tmp`   | Almacena archivos temporales.                     |

3.- Una carpeta y un grupo no son lo mismo y este comando lo aclara :

**sudo chown -R root:desarrollo /empresa/desarrollo**

Signficia que root es el usuario propietario de la carpeta desarrollo y desarollo es el grupo asociado a esa carpeta.

Cada archio y carpeta tiene 3 datos importantes:
a) Usuario propietario: Uma cuenta de usuario
b) Grupo propietario: Un grupo de usuarios
c) Permisos: determinan quién puede leer, escribir o acceder

**En sudo chmod 2770 /empresa/desarrollo**

el 2 inicial activa setgid en el directorio: los nuevos archivos y subdirectorios heredan el grupo propietario

sudo chmod -R u+rwX,g+rwX,o-rwx /empresa/desarrollo

x minúscula: Agrega permiso de ejecución siempre

X: Agrega ejecución solo si el directorio o el archivo ya tenian algún permiso de ejecución

El propietario de un archivo es el usuario que lo creó.

**05/ 11/2026**

Reinicar la instancia me garantiza que el IP pública se mantendrá igual

5.- Proceso: Programa que se ejecuta en el SO. Servicio: Conjunto de procesos que generan una funcionalidad.

| Proceso                                  | Servicio                                          |
| ---------------------------------------- | ------------------------------------------------- |
| `sleep 600`                            | `httpd`(Apache)                                 |
| Espera 600 segundos.                     | Atiende solicitudes HTTP.                         |
| Se puede administrar con`ps`y`kill`. | Se administra normalmente con`systemctl`.       |
| Tiene un PID.                            | Puede ejecutar varios procesos con distintos PID. |

6.- **journalctl** es como un historial de acontecimientos: Permite consultar qué ocurrió con los servicios del servidor

**logrotate** es como el encargado de organizar y archivar registros: Evita que los archivos de logs crezcan indefinidamente

En linux, un archivo se considera oculto cuando comienza con un punto (.)

| Símbolo          | Significado                                           |
| ----------------- | ----------------------------------------------------- |
| `~`(virgulilla) | Directorio personal                                   |
| `.`             | Directorio actual                                     |
| `..`            | Directorio padre (anterior)                           |
| `>/`            | Directorio raíz cuando aparece al inicio de una ruta |

7. Un alias creado directamente en la terminal solo existe durante esa sesión, desaparece al cerrarla. Al guardarla en .bashrc, Bash lo carga automáticamente cada vez que inicias una nueva sesión interactiva.

Existe sesión interactiva y no interactiva: `echo "$-" >> script.sh`
echo '[[[[$- == *i*]]]] && echo "¡Bienvenido al servidor de $EMPRESA!"' >> ~/.bashr


**07/11/2026**

Los scripts idempotentes son útiles para automatizar la configuración de servidores

Es necesario crear una política IAM para que nuestra instancia suba los backups al bucket S3

Política IAM: define qué acciones están permitidas.

Rol IAM: permite que un servicio como EC2 utilice esos permisos.

Podemos ejecutar un script al momento de hacer la creación manual de la instancia EC2 en Datos de Usuario:

Provisionamiento manual: crear EC2 y después ejecutar el script.
Provisionamiento automatizado: crear EC2 y dejar que User Data ejecute el script.
