#!/bin/bash

#fomat first argument YYYYMMDD

BACKUPDAY=$1
#auth data in domain
HOST=blank #ip or hostname
BACKUPSDIR=ZabbixBackup #folder where sored backups dirs
USER=blank #username
DOMAIN=blank #like domain.com or workgroup
PASSWORD=blank
MNTPATH=/mnt/smbmnt #mountpoint of remote shared folder

DAY=`date +%Y%m%d`
set_date ()
{
DT=`date "+%y%m%d %H:%M:%S"`
}

set_date
echo -e "$\nDT Mounting SMB-catalogue"
mount -t cifs -o username=$USER,password=$PASSWORD,domain=$DOMAIN //$HOST/$BACKUPSDIR $MNTPATH/
set_date
echo -e "$DT Stopping services"
service zabbix-server stop
service mysql stop 2
set_date
echo -e "$DT Services are stopped"
set_date
echo -e "$DT Starting unpacking backups files"
mkdir /tmp/zabbix_db/
mkdir /tmp/zabbix_files/
tar -xzf $MNTPATH/Zabbix_$BACKUPDAY/zabbix_db_$BACKUPDAY.tar.gz -C /tmp/zabbix_db/
tar -xzf $MNTPATH/Zabbix_$BACKUPDAY/zabbix_files_$BACKUPDAY.tar.gz -C /tmp/zabbix_files/
set_date
echo -e "$DT Вackup files are unpacked"
echo -e "$DT Deleting .old directories"
find /var/lib/mysql.old* -type f -exec rm -rf {} \;
find /var/lib/mysql.old* -type d -name "*" -empty -delete
find /usr/share/zabbix.old* -type f -exec rm -rf {} \;
find /usr/share/zabbix.old* -type l -exec rm -rf {} \;
find /usr/share/zabbix.old* -type d -name "*" -empty -delete
set_date
echo -e "$DT .old directories are removed"
echo -e "$DT Copying files"
mv /var/lib/mysql/ /var/lib/mysql.old_$DAY
mv /usr/share/zabbix/ /usr/share/zabbix.old_$DAY
innobackupex --copy-back /tmp/zabbix_db/xtra/ 2>&1 | tee /var/log/innobackupex.log | egrep "ERROR|innobackupex: completed OK"
chown -R mysql:mysql /var/lib/mysql
cp -r /tmp/zabbix_files/* /usr/share/zabbix/
set_date
echo -e "$DT Files are copied"
set_date
echo -e "$DT Starting services"
service mysql start 2
service zabbix-server start 2
set_date
echo -e "$DT Services are started\nRestore complete\"
umount $MNTPATH/
rm -rf /tmp/zabbix_db
rm -rf /tmp/zabbix_files
