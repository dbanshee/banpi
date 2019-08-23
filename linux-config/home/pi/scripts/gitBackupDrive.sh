#! /bin/bash

#
# Banpi Script for Git Server Backup to GDrive
#

FILE_BACKUP_PATH=/home/pi/scripts/fileBackupDrive.sh
GIT_SERVER_PATH=/usr/local/git-server
DRIVE_FOLDER=git


function abort () {
  echo " Aborting Git Backup Drive Execution"
  exit -1
}

trap abort SIGTERM SIGKILL SIGINT

echo "---------------------------------------------------------"
echo "Git Backup Drive - $(date)"
echo "  Git Folder          : ${GIT_SERVER_PATH}"
echo "  GDrive Folder       : ${DRIVE_FOLDER}"
echo "---------------------------------------------------------"
echo

# Git Repositories Backup
for gitRep in $(find $GIT_SERVER_PATH -maxdepth 2 -name '*.git' -type d) ; do
  repName=$(basename $gitRep)
  echo " Found Git Repository : $gitRep"
  echo

  backupCmd="${FILE_BACKUP_PATH} $gitRep $DRIVE_FOLDER"
  echo " Backup Cmd : $backupCmd"

  eval $backupCmd
  if [ $? == 0 ] ; then
    echo " Backup Repository ${repName} finished"
  else
    echo " Backup Repository ${repName} finished with errors"
  fi
  echo
done

echo "---------------------------------------------------------"
echo "Git Backup Drive finished at $(date)"
echo "---------------------------------------------------------"
echo

