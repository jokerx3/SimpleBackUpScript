#!/bin/bash
#This script is written by Tim Carlsson and Franz-Henry Baitz
#it comes with absolutly no warrenty
#
#Creative Commons License 3.0 cc-by-sa
#
#See Details: http://creativecommons.org/licenses/by-sa/3.0/

#Paths and Filenames
savedata=/home/yourusername/save/*
backupFileExt=.tgz
backupFile=Backup_$(date +"%F_%H-%M")$backupFileExt
backupContent=$backupFile.txt
scriptLogFile=/var/log/autobackup.log

#FTP stuff
ftpUser=#USER
ftpPassword=#PASSWORD
ftpHostname=#URL
ftpRemotePath=#FTPPATH

#E-Mail stuff
#mailReciever="root@localhost"
mailReciever="user@domain.de"
mailSubject="Backup on $HOSTNAME to $ftpHostname"
mailMessage="/tmp/emailmessage.txt"

#error vars
archivStatus=0
ftpStatus=0

cd "/root"

#create tarball
tar czf $backupFile $savedata;
archivStatus=$?
#read content from the archive and it in the txt
tar tf $backupFile > $backupContent;
#get filesize
contentFilesize=$(ls -l $backupContent | tr -s " " | cut -d " " -f 5)
#rar a -s -m5 $backupFile $savedata;
#if the content filesize not equals 0; then
if [ ${contentFilesize:-0} -ne 0 ]; then
    echo "$backupFile in $PWD created" > $scriptLogFile
    #upload the backup file via ftp
    ftp -u ftp://$ftpUser:$ftpPassword@$ftpHostname$ftpRemotePath/$backupFile $backupFile;
    ftpStatus=$?
    #if the upload was successful
    if [ ${ftpStatus:-255} -eq 255 ]; then
      echo "upload to $ftpHostname complete" >> $scriptLogFile
      #if backup was successful, delete the archive
      rm -f $backupFile
    #if the upload failed
    else
      echo "upload to $ftpHostname failed" >> $scriptLogFile
    fi
#if the backup was not created
else 
    echo "$backupFile in $PWD failed" > $scriptLogFile
fi

#mail text
echo "This is an auto-generated e-mail from $HOSTNAME."> $mailMessage
echo "The daily backup on $(date +"%c")" >> $mailMessage
echo "" >> $mailMessage
echo "Creating the Backupfile was" >> $mailMessage
echo "" >> $mailMessage
#if the archive created successfully
if [ ${archivStatus:-0} -eq 0 ]; then
  echo "        S U C C E S S F U L " >> $mailMessage
  echo "" >> $mailMessage
  echo "The Backup upload to $ftpHostname was" >> $mailMessage
  echo "" >> $mailMessage
  #if the upload was all good
  if [ ${ftpStatus:-255} -eq 255 ]; then
    echo "        S U C C E S S F U L " >> $mailMessage
    echo "" >> $mailMessage
    echo "Backup is saved at $ftpHostname:$ftpRemotePath/$backupFile" >> $mailMessage
  #if the archive was successful and the upload failed
  else
    echo "        N O T  successful" >> $mailMessage
    echo "" >> $mailMessage
    echo "The Backup file is stored in $HOSTNAME:$PWD/$backupFile" >> $mailMessage
    echo "" >> $mailMessage
    echo "Please contact your Systemadminstrator" >> $mailMessage
  fi
  echo "" >> $mailMessage
  echo "Attachment: $backupContent" >> $mailMessage
  /bin/mail -s "$mailSubject" -a $backupContent "$mailReciever" < $mailMessage;
#if the archiv failed
else
  echo "        N O T  successful" >> $mailMessage
  echo "" >> $mailMessage
  echo "Please contact your Systemadminstrator" >> $mailMessage
  /bin/mail -s "$mailSubject" "$mailReciever" < $mailMessage;
fi
  echo "mail sent to $mailReciever" >> $scriptLogFile
exit
