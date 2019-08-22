#! /bin/bash

#
# Banpi Script for Git Server Backup to GDrive
#

FILE_BACKUP_PATH=/home/pi/scripts/fileBackupDrive.sh
GIT_SERVER_PATH=/usr/local/git-server
DRIVE_FOLDER=git

# Git Repositories Backup
for gitRep in $(find $GIT_SERVER_PATH -maxdepth 2 -name '*.git' -type d) ; do
  #gitRepPath="${GIT_SERVER_PATH}/${gitRep}"
  echo " Found Git Repository : $gitRep"
  backupCmd="${FILE_BACKUP_PATH} $gitRep $DRIVE_FOLDER"
  echo "Backup Cmd : $backupCmd"
  eval $backupCmd
done

