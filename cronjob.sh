40 4 * * * /etc/webmin/cron/tempdelete.pl #Delete Webmin temporary files
#min  hour  day  month  dow  user  command
#Command execute every day
#autobackup.sh is a simple ftp filebackup script with an email notification
 0     22     *     *     *   root  /root/autobackup.sh
