# backup-zabbix-db
Bash script for backup Zabbix: database and configs.

This script is using for backup MySQL innodb database files without mysqldump and database locking, using Percona Xtrabackup. Also, backups of configuration files and backend will be created. As backup server used any host of Windows workgroup.  
Before start backuping, you have to install percona-xtrabackup

To restore db and backend, pleare execute restore_zabbix.sh with argument contains date to restore, like ./restore_zabbix.sh 20191231

To restore config files which contains in /etc/, you can copying it manually.

That solution fully tested on Ubuntu Server 18.04 with Zabbix 4.2.3 and MySQL 5.7.27
