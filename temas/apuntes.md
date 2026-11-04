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

X: Agrega ejecució solo si el directorio o el archivo y tenian algún permiso de ejecución

El propietario de un archivo es el usuario que lo creó.


4.- Es importante hacer algo
