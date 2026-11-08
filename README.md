# # AWS re/Start — Linux Administration & Automation

# A hands-on project developed as part of **AWS re/Start — Module 2**, focused on Linux system administration, cloud infrastructure, security, and automation using AWS.

# Throughout eight practical missions, I configured and managed Amazon Linux 2023 EC2 instances, deployed an Apache web server, managed Linux users and permissions, monitored system logs, and automated reporting and backups using Bash, cron, IAM, and Amazon S3.

# ## Technologies Used

# | Technology | Purpose |

# |---|---|

# | Amazon EC2 | Linux virtual servers |

# | Amazon Linux 2023 | Operating system |

# | Amazon S3 | Cloud backup storage |

# | AWS IAM | Secure access management |

# | Bash | Shell scripting and automation |

# | Apache HTTP Server | Web hosting |

# | Cron | Scheduled task automation |

# | SSH / SCP | Secure remote access and file transfers |

# | Git & GitHub | Version control |

# ## Project Architecture

# ```text

# Local Computer (Windows)

#         |

#         | SSH / SCP

#         v

# Amazon EC2 — Amazon Linux 2023

#         |

#         +-- Linux users and groups

#         |      +-- desarrollo: ana, luis

#         |      +-- finanzas: carla

#         |

#         +-- /empresa

#         |      +-- desarrollo/

#         |      +-- finanzas/

#         |      +-- publico/

#         |             +-- LEEME.txt

#         |             +-- reportes/

#         |

#         +-- Apache HTTP Server

#         |      +-- /var/www/html/index.html

#         |      +-- /var/log/httpd/access_log

#         |

#         +-- Bash Automation

#                +-- setup-servidor.sh

#                +-- reporte.sh

#                +-- backup.sh

#                        |

#                        | IAM Role

#                        v

#                   Amazon S3

#                   backups/*.tar.gz

# Cron schedules reports and backups.

# ```

# ## Repository Structure

# ```text

# aws-restart-02-linux/

# ├── proyecto/

# │   ├── capturas/

# │   │   ├── Uso_de_cron.png

# │   │   └── Uso_de_setup.sh_para_otra_instancia.png

# │   ├── codigo/

# │   │   ├── setup-servidor.sh

# │   │   ├── reporte.sh

# │   │   └── backup.sh

# │   └── temas/

# │       ├── apuntes.md

# │       └── ERRORES.md

# └── README.md

# ```

# - **codigo/** — Bash scripts used to automate system administration tasks.

# - **capturas/** — Screenshots documenting implementation and testing.

# - **temas/apuntes.md** — Linux and AWS learning notes.

# - **temas/ERRORES.md** — Errors encountered and lessons learned.

# ## Practical Missions

# ### Mission 1 — EC2 and SSH Connectivity

# Launched an Amazon Linux 2023 EC2 instance and established a secure connection from Windows PowerShell.

# **Configuration:**

# - Instance type: `t3.micro`

# - Region: `us-east-2` (Ohio)

# - SSH authentication using an RSA `.pem` key pair

# - Security group restricting port 22 to my public IP

# ```powershell

# ssh -i "$HOME\Downloads\andes-key.pem" ec2-user@PUBLIC_IP

# ```

# Explored essential Linux commands:

# ```bash

# whoami

# hostname

# cat /etc/os-release

# uname -r

# pwd

# ls --help

# ```

# **Key learning:** SSH access should be restricted to authorized IP addresses rather than exposed to `0.0.0.0/0`.

# ### Mission 2 — Linux Users and Groups

# Created Linux groups and user accounts to simulate an organization's departments.

# | User | Department | Administrator |

# |---|---|---|

# | ana | desarrollo | Yes |

# | luis | desarrollo | No |

# | carla | finanzas | No |

# Practiced:

# ```bash

# sudo groupadd desarrollo

# sudo useradd -m -G desarrollo ana

# sudo usermod -aG wheel ana

# id ana

# ```

# Explored `/etc/passwd`, `/etc/group`, and the purpose of `/etc/shadow`.

# **Key learning:** Linux controls access through users, groups, file ownership, and permissions.

# ### Mission 3 — File System Administration

# Created a departmental directory structure under `/empresa`.

# Practiced file management using:

# ```bash

# mkdir

# touch

# cp

# mv

# rm

# find

# tar

# ```

# Created a server usage guide with Vim and compressed the company directory into a `.tar.gz` archive.

# **Key learning:** Understanding Linux directories and file operations is essential for server administration.

# ### Mission 4 — File Permissions and Security

# Configured departmental access restrictions.

# | Directory | Owner | Group | Permissions |

# |---|---|---|---|

# | `/empresa/desarrollo` | root | desarrollo | 2770 |

# | `/empresa/finanzas` | root | finanzas | 2770 |

# | `/empresa/publico` | ana | ana | 755 |

# Example:

# ```bash

# sudo chmod 2770 /empresa/desarrollo

# sudo chmod 2770 /empresa/finanzas

# sudo chmod 755 /empresa/publico

# ```

# Used the **setgid bit** to ensure new files inherit their parent directory's group.

# Verified that unauthorized users could not access restricted directories.

# **Key learning:** Permissions enforce separation between departments and protect organizational data.

# ### Mission 5 — Software, Services, and Processes

# Installed and configured Apache HTTP Server.

# ```bash

# sudo dnf install -y httpd tree

# sudo systemctl enable --now httpd

# sudo systemctl status httpd

# ```

# Created a basic Andes Tech website in:

# ```text

# /var/www/html/index.html

# ```

# Configured HTTP access on port 80 exclusively from my public IP.

# Inspected processes and network ports:

# ```bash

# sudo ss -ltnp

# ps aux

# kill PID

# ```

# Rebooted EC2 and verified Apache started automatically.

# **Key learning:** `systemd` manages Linux services, while process-management commands help monitor and control running programs.

# ### Mission 6 — Logs and Pipelines

# Monitored Apache requests in real time:

# ```bash

# sudo tail -f /var/log/httpd/access_log

# ```

# Generated successful HTTP requests and intentional `404 Not Found` errors.

# Analyzed access logs using pipelines and AWK to calculate:

# - Total HTTP requests

# - Number of HTTP 404 responses

# - Most frequent client IP addresses

# Investigated service logs:

# ```bash

# sudo journalctl -u httpd -n 30 --no-pager

# ```

# Explored log rotation:

# ```bash

# sudo cat /etc/logrotate.d/httpd

# systemctl list-timers --all

# ```

# **Key learning:** Logs help diagnose failures, monitor activity, and understand server behavior. Log rotation prevents uncontrolled growth of log files.

# ### Mission 7 — Shell Customization

# Customized the Bash environment using `.bashrc`.

# Created a shortcut for Apache log monitoring:

# ```bash

# alias logs='sudo tail -n 10 -F /var/log/httpd/access_log'

# ```

# Configured a persistent environment variable:

# ```bash

# export EMPRESA=AndesTech

# ```

# Added a welcome message displayed when opening an interactive Bash session.

# **Key learning:** `.bashrc` allows shell configuration to persist across interactive sessions.

# ### Mission 8 — Final Automation Project

# Developed three Bash scripts to automate server administration.

# #### `setup-servidor.sh`

# Automates configuration from Missions 2–4:

# - Creates Linux groups and users.

# - Configures departmental memberships.

# - Grants administrative privileges to `ana`.

# - Creates the `/empresa` directory structure.

# - Configures ownership and permissions.

# - Applies setgid to departmental directories.

# - Avoids recreating existing accounts and groups.

# The script was designed to be **idempotent**, meaning repeated execution maintains the intended configuration without duplicating resources.

# #### `reporte.sh`

# Generates a daily system report at:

# ```text

# /empresa/publico/reportes/reporte-YYYY-MM-DD.txt

# ```

# Includes:

# - Date and time

# - Server hostname

# - System uptime

# - Disk usage

# - Memory usage

# - Top five processes by memory consumption

# - Apache service status

# - Most frequent HTTP client IP addresses

# #### `backup.sh`

# Creates a compressed archive of `/empresa` and uploads it to Amazon S3.

# ```text

# EC2

#  |

#  +-- /empresa

#        |

#        v

#      tar.gz

#        |

#        v

#    IAM Role

#        |

#        v

#   Amazon S3

# ```

# Configured a dedicated IAM role with permissions restricted to uploading backup objects to a specific S3 bucket prefix.

# **Key learning:** EC2 can access AWS services using temporary credentials provided by IAM roles, avoiding hardcoded access keys.

# ## Task Scheduling with Cron

# Installed and enabled the cron service on Amazon Linux 2023:

# ```bash

# sudo dnf install -y cronie

# sudo systemctl enable --now crond

# ```

# Initially tested automated tasks every five minutes.

# Then configured daily execution through `/etc/cron.d/andes-tech`:

# ```cron

# 0 3 * * * root /usr/local/bin/reporte.sh >> /var/log/andes-reporte.log 2>&1

# 10 3 * * * root /usr/local/bin/backup.sh >> /var/log/andes-backup.log 2>&1

# ```

# These schedules use the server's timezone, which was UTC during testing.

# Verified that scheduled reports were generated successfully and backups were uploaded to S3.

# **Note:** Cron jobs execute only while the EC2 instance is running.

# ## Final Validation — Fresh EC2 Instance

# To validate the automation, I launched a second EC2 instance running Amazon Linux 2023.

# I transferred and executed `setup-servidor.sh` on the new server.

# **Validation results:**

# - Users and groups were created successfully.

# - Departmental directories were generated.

# - Ownership and permissions were configured.

# - Administrative access was assigned.

# - Unauthorized directory access was denied.

# - Running the script again completed without recreating existing users.

# This exercise demonstrated **repeatable server configuration and practical idempotency**.

# It also introduced EC2 User Data as an option for automatically executing setup scripts during the initial instance launch.

# ## Security Practices

# Throughout the project, I applied several security principles:

# - Restricted SSH and HTTP access to authorized IP addresses.

# - Used SSH private keys instead of password-based SSH authentication.

# - Implemented departmental access restrictions.

# - Applied the principle of least privilege with IAM.

# - Used IAM roles rather than permanent AWS access keys on EC2.

# - Kept Amazon S3 backups private.

# - Avoided committing credentials and private keys to GitHub.

# - Removed temporary cloud resources after completing the exercises.

# ## Project Results

# By completing this module, I gained hands-on experience in:

# 1. Provisioning and accessing Linux servers on AWS.

# 2. Managing users, groups, and permissions.

# 3. Deploying and managing web services.

# 4. Monitoring processes, logs, and system resources.

# 5. Creating Bash scripts for operational automation.

# 6. Scheduling recurring tasks using cron.

# 7. Integrating EC2 with Amazon S3 through IAM roles.

# 8. Reproducing server configurations on a fresh instance.

# ## Conclusion

# This project helped me understand how Linux administration and AWS cloud services work together in real-world infrastructure environments.

# The most important takeaway was learning how to move from **manual server configuration to repeatable automation**, while maintaining security, monitoring, and backup practices.

# It provides a practical foundation for further learning in **Cloud Computing, DevOps, Infrastructure as Code, and AWS automation**.

# ---

# **Project:** AWS re/Start — Module 2  

# **Environment:** Amazon Linux 2023 · AWS EC2 · Amazon S3  

# **Status:** Complete
