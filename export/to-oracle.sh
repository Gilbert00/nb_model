#! /usr/bin/sh

LOG="/home/root/netbackup.out"
NLS_LANG="AMERICAN_AMERICA.CL8MSWIN1251"
PATH=/opt/openv/bin:/opt/openv/netbackup/bin:/opt/openv/netbackup/bin/goodies:/opt/openv/netbackup/bin/admincmd:$PATH
export NLS_LANG PATH

/usr/openv/netbackup/bin/cluster/cluster_active
if [ ! $? ]; then exit; fi

echo "\n" >> $LOG
echo "Start: " >> $LOG
date >> $LOG
cd   ~/to_oracle
perl -w netbackup.pl 2>&1 | tee -a $LOG
echo "End: " >> $LOG
date >> $LOG


