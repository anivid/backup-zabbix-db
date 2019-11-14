# backup-zabbix-db
Bash script for backup Zabbix: database, backend and configs.
That is using for backup MySQL innodb database files without mysqldump and database locking, using Percona Xtrabackup. Also, backups of configuration files and backend will be created. As backup server used any host of Windows workgroup.

### Before use
Before start backuping, you have to install percona-xtrabackup and cifs-utils. Also you have to fill your credentials in .sh files.

    # apt-get install percona-xtrabackup cifs-utils
### Use
In order to backup zabbix, execute:

    # ./backup_zabbix.sh
To restore db and backend, you have to execute restore_zabbix.sh with argument contains date to restore, like:

    # ./restore_zabbix.sh 20191231
To restore config files which contains in /etc/, you can copying it manually or add necessary commands to script.

That solution fully tested on Ubuntu Server 18.04 with Zabbix 4.2.3 and MySQL 5.7.27
