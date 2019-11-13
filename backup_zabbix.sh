#!/bin/bash

#auth data in domain
HOST=blank
BACKUPFOLDER=blank
USER=blank
DOMAIN=blank
PASSWORD=blank

USER_BD=blank
PASSWORD_BD=blank

DAY=`date +%Y%m%d`
LOGFILE=/var/log/zabbix_backup.log
LOGTEMP=/tmp/zbxlog.tmp
# backup local dir
BK_GLOBAL=/root/backups
# backup current dir
BK_DIR=$BK_GLOBAL/Zabbix_$DAY
#for addind date and time in log
set_date ()
{
DT=`date "+%y%m%d %H:%M:%S"`
}

set_date
echo -e "$DT Mounting SMB-catalogue\n" > $LOGTEMP
mount -t cifs -o username=$USER,password=$PASSWORD,domain=$DOMAIN //$HOST/$BACKUPFOLDER /mnt/smbmnt/
mkdir $BK_DIR
set_date
echo -e "$DT Starting backup database Zabbix" >> $LOGTEMP
service zabbix-server stop 2>>$LOGTEMP
innobackupex --user=$USER_BD --password=$PASSWORD_BD --no-timestamp $BK_DIR/xtra 2>&1 | tee /var/log/innobackupex.log | egrep "ERROR|innobackupex: completed OK" >>$LOGTEMP
innobackupex --apply-log --use-memory=1000M $BK_DIR/xtra 2>&1 | tee /var/log/innobackupex.log | egrep "ERROR|innobackupex: completed OK" >>$LOGTEMP
service zabbix-server start 2>>$LOGTEMP
set_date
echo -e "$DT Backup database complete" >> $LOGTEMP
set_date
echo -e "$DT Start archiving" >> $LOGTEMP
cd $BK_DIR
tar -cf $BK_DIR/zabbix_db_$DAY.tar ./xtra 2>>$LOGTEMP
rm -rf $BK_DIR/xtra
cd /usr/share
tar -cf $BK_DIR/zabbix_files_$DAY.tar ./zabbix 2>>$LOGTEMP
cd /etc
tar -cf $BK_DIR/zabbix_etc_$DAY.tar ./zabbix 2>>$LOGTEMP
cd /
gzip $BK_DIR/zabbix_db_$DAY.tar 2>>$LOGTEMP
gzip $BK_DIR/zabbix_files_$DAY.tar 2>>$LOGTEMP
gzip $BK_DIR/zabbix_etc_$DAY.tar 2>>$LOGTEMP
set_date
echo -e "$DT Archiving complete" >> $LOGTEMP
rm -f zabbix_db_$DAY.tar
rm -f zabbix_files_$DAY.tar
rm -f zabbix_etc_$DAY.tar
set_date
echo -e "$DT Starting copying data on the backup server" >> $LOGTEMP
mkdir /mnt/smbmnt/Zabbix_$DAY
cp $BK_DIR/zabbix_db_$DAY.tar.gz /mnt/smbmnt/Zabbix_$DAY 2>>$LOGTEMP
cp $BK_DIR/zabbix_files_$DAY.tar.gz /mnt/smbmnt/Zabbix_$DAY 2>>$LOGTEMP
cp $BK_DIR/zabbix_etc_$DAY.tar.gz /mnt/smbmnt/Zabbix_$DAY 2>>$LOGTEMP
set_date
echo -e "$DT Copying complete" >> $LOGTEMP
echo -e "$DT Removing old archives" >> $LOGTEMP
find $BK_GLOBAL/* -type f -ctime +30 -exec rm -rf {} \;  2>>$LOGTEMP
find /mnt/smbmnt/* -type f -ctime +30 -exec rm -rf {} \;  2>>$LOGTEMP
find $BK_GLOBAL/* -type d -name "*" -empty -delete 2>>$LOGTEMP
find /mnt/smbmnt/* -type d -name "*" -empty -delete 2>>$LOGTEMP
set_date
echo -e "$DT Removing complete\nend_log" >> $LOGTEMP
cat $LOGTEMP >> $LOGFILE
sed -i -e "1 s/^/Subject: Zabbix backup log $DAY\n\n/;" $LOGTEMP 2>>$LOGFILE
echo -e "\nList of $BK_DIR:\n" >> $LOGTEMP
ls -lh $BK_DIR >> $LOGTEMP
echo -e "\nDiskspace usage:\n" >> $LOGTEMP
df -h >> $LOGTEMP
set_date
sed -i "/end_log/ s/end_log/$DT Unmount SMB-catalogue/" $LOGTEMP 2>>$LOGFILE
cp $LOGTEMP /mnt/smbmnt/Zabbix_$DAY/LOG.log
umount /mnt/smbmnt 2>>$LOGTEMP
rm -rf $BK_DIR
