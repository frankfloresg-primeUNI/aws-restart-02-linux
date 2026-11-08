# AWS re/Start — Linux Administration & Automation

Hands-on project for **AWS re/Start, Module 2**. Across eight missions, I configured Amazon Linux 2023 servers on EC2, deployed Apache, managed Linux users and permissions, monitored logs and processes, and automated reports and backups to Amazon S3.

## Technology stack

| Technology | Purpose |
| --- | --- |
| Amazon EC2 / Amazon Linux 2023 | Linux servers |
| Amazon S3 | Backup storage |
| AWS IAM | Role-based permissions without long-lived keys on EC2 |
| Bash | Server automation |
| Apache HTTP Server (`httpd`) | Web hosting |
| `cronie` / `crond` | Scheduled jobs |
| SSH / SCP | Remote access and file transfers |
| Git / GitHub | Version control and documentation |

## Architecture

```text
Windows + PowerShell
       | SSH / SCP
       v
EC2: Amazon Linux 2023
       |
       +-- /empresa/
       |     +-- desarrollo/   (ana, luis)
       |     +-- finanzas/     (carla)
       |     +-- publico/      (LEEME.txt, reportes/)
       |
       +-- Apache (httpd)
       |     +-- /var/www/html/index.html
       |     +-- /var/log/httpd/access_log
       |
       +-- Bash scripts
             +-- setup-servidor.sh
             +-- reporte.sh  <--- cron
             +-- backup.sh   <--- cron
                    |
                    | EC2 IAM role
                    v
             Amazon S3: backups/*.tar.gz
```

## Repository structure

```text
aws-restart-02-linux/
├── proyecto/
│   ├── capturas/       # Screenshots and test evidence
│   ├── codigo/
│   │   ├── setup-servidor.sh
│   │   ├── reporte.sh
│   │   └── backup.sh
│   └── temas/
│       ├── apuntes.md
│       └── ERRORES.md
└── README.md
```

## Missions

### 1. EC2 and SSH

- Launched an Amazon Linux 2023 `t3.micro` instance in Ohio (`us-east-2`).
- Created an RSA `.pem` key pair and limited inbound SSH (port 22) to **My IP**.
- Connected from Windows PowerShell and inspected the username, hostname, OS, kernel and current directory.

```powershell
ssh -i "$HOME\Downloads\andes-key.pem" ec2-user@PUBLIC_IP
```

Useful commands: `whoami`, `hostname`, `cat /etc/os-release`, `uname -r`, `pwd`, `ls --help`.

### 2. Users and groups

Created `desarrollo` and `finanzas` groups and three user accounts:

| User | Group | Admin privileges |
| --- | --- | --- |
| `ana` | `desarrollo` | Yes (`wheel` / `sudo`) |
| `luis` | `desarrollo` | No |
| `carla` | `finanzas` | No |

Used `groupadd`, `useradd`, `passwd`, `usermod`, `id`, and `getent`. Studied `/etc/passwd`, `/etc/group` and protected password metadata in `/etc/shadow`.

### 3. Company directory structure

Created `/empresa/{desarrollo,finanzas,publico}`, wrote `LEEME.txt` using Vim, and practiced `touch`, `cp`, `mv`, `find`, and `tar`. Learned the roles of `/etc`, `/var`, `/home`, and `/tmp`.

### 4. Permissions and setgid

Configured restricted departmental directories and a publicly readable directory:

| Directory | Owner | Group | Mode |
| --- | --- | --- | --- |
| `/empresa/desarrollo` | `root` | `desarrollo` | `2770` |
| `/empresa/finanzas` | `root` | `finanzas` | `2770` |
| `/empresa/publico` | `ana` | `ana` | `755` |

The leading `2` enables **setgid**, so new items created inside a departmental directory inherit that directory's group. Verified that `carla` could not access `/empresa/desarrollo`. Note: setgid does not by itself guarantee group-write permission on every newly created file.

### 5. Software, services and processes

Installed Apache and `tree` with `dnf`, started Apache and enabled it at boot:

```bash
sudo dnf install -y httpd tree
sudo systemctl enable --now httpd
sudo systemctl status httpd
```

Published an Andes Tech test page in `/var/www/html/index.html`, allowed inbound HTTP (port 80) only from **My IP**, inspected listening processes with `ss`, and tested background processes with `sleep`, `ps`, and `kill`. Restarted EC2 and verified Apache started automatically.

### 6. Logs and pipelines

Observed incoming HTTP requests, deliberately generated `404` responses, and analyzed Apache access logs with `awk` and pipes.

```bash
sudo tail -n 0 -f /var/log/httpd/access_log
sudo journalctl -u httpd -n 30 --no-pager
sudo cat /etc/logrotate.d/httpd
systemctl list-timers --all | grep logrotate
```

Learned the distinction between Apache access logs, the `systemd` journal and `logrotate` (which rotates and archives log files according to configured rules).

### 7. Shell customization

Added a persistent `logs` alias, an environment variable, and a welcome message to `~/.bashrc`:

```bash
alias logs='sudo tail -n 10 -F /var/log/httpd/access_log'
export EMPRESA=AndesTech
[[ $- == *i* ]] && echo "Welcome to the $EMPRESA server!"
```

Verified that the settings persisted after signing out and reconnecting over SSH.

### 8. Final automation project

**`setup-servidor.sh`** — Reproduces the user/group, directory and permissions configuration from Missions 2–4. Tested it on the original instance and on a fresh EC2 instance. Re-running it completed without duplicate-account errors, preserving an existing test file. New accounts on the fresh instance required initial password setup.

**`reporte.sh`** — Writes a dated file at `/empresa/publico/reportes/reporte-YYYY-MM-DD.txt` containing the date/time, hostname, uptime, disk and memory usage, top five processes by memory, Apache status, and frequent HTTP client IPs.

**`backup.sh`** — Compresses `/empresa` into a `.tar.gz` archive and uploads it under `backups/` in a private S3 bucket. An attached **EC2 IAM role** provides temporary credentials; no permanent access keys are stored in the script.

#### Cron scheduling

Installed and enabled the scheduler:

```bash
sudo dnf install -y cronie
sudo systemctl enable --now crond
```

Tested the report and backup jobs every five minutes, then configured daily tasks in `/etc/cron.d/andes-tech`:

```cron
0 3 * * * root /usr/local/bin/reporte.sh >> /var/log/andes-reporte.log 2>&1
10 3 * * * root /usr/local/bin/backup.sh >> /var/log/andes-backup.log 2>&1
```

These times follow the server's configured timezone (UTC during testing). Cron jobs do **not** run while an EC2 instance is stopped. Before the backup job can run, the S3 bucket, EC2 role and any script-specific bucket configuration must be set up.

#### Fresh-instance validation

Launched a second Amazon Linux 2023 EC2 instance, transferred `setup-servidor.sh`, created the user accounts, and verified departmental access controls. Ran the script again to check repeatability. This validation reproduced the **Missions 2–4 configuration**, not Apache or the complete contents of the original instance.

**Bonus explored:** EC2 **User Data** can run a noninteractive initialization script during the first boot. Avoid putting passwords or other secrets in User Data.

## Security practices

- Restricted inbound SSH and HTTP to an authorized IP instead of opening them to the entire internet.
- Used SSH key-based login and protected the `.pem` file's permissions.
- Applied Linux group-based access control and IAM least privilege.
- Used an EC2 IAM role instead of hardcoding AWS access keys.
- Kept backups in a private S3 bucket.
- Avoided including private keys, credentials or password hashes in the repository.
- Cleaned up test cloud resources to reduce unnecessary charges.

## Key takeaways

This module strengthened my understanding of Linux administration, monitoring and cloud security. The main outcome was learning how to turn manual configuration into **repeatable Bash automation**, schedule operating tasks, and store backups securely on AWS.

**Status:** Eight missions completed and final automation tested.

> **Disclaimer:** These scripts were developed in a learning environment. Production deployments would need additional validation, error handling, IAM review, backup restoration tests and infrastructure lifecycle controls.
