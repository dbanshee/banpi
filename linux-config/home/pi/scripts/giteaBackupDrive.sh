#! /bin/bash

#
# Banpi Script for Gitea Server Backup to GDrive
#

TMP_PATH=/tmp-nolimit
FILE_BACKUP_PATH=/home/pi/scripts/fileBackupDrive.sh
GITEA_PATH=/usr/local/gitea
GITEA_COMMAND_PATH="$GITEA_PATH/gitea"
GITEA_CONFIG_FILE_PATH="${GITEA_PATH}/custom/conf/app.ini"
GITEA_BACKUP_PATH="${TMP_PATH}/gitea-dump.zip"
GIT_SERVER_PATH=/usr/local/gitea/gitea-repositories
DRIVE_FOLDER=gitea

function abort () {
  echo " Aborting Gitea Backup Drive Execution"
  exit -1
}

trap abort SIGTERM SIGKILL SIGINT

echo "---------------------------------------------------------"
echo "Gitea Backup Drive - $(date)"
echo "  Git Folder          : ${GIT_SERVER_PATH}"
echo "  GDrive Folder       : ${DRIVE_FOLDER}"
echo "---------------------------------------------------------"
echo

echo " Backup Gitea Repositories at ${GIT_SERVER_PATH}"
# Git Repositories Backup
for gitRep in $(find $GIT_SERVER_PATH -maxdepth 2 -name '*.git' -type d) ; do
  repName=$(basename ${gitRep})
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

# Gitea App
pushd .
cd $TMP_PATH

rm -f gitea-dump-*
giteaBackupCmd="${GITEA_COMMAND_PATH} dump --tempdir ${TMP_PATH} --skip-repository -c ${GITEA_CONFIG_FILE_PATH}"
echo " Gitea Backup Cmd : ${giteaBackupCmd}"
eval $giteaBackupCmd
mv gitea-dump-*.zip $GITEA_BACKUP_PATH

backupCmd="${FILE_BACKUP_PATH} ${GITEA_BACKUP_PATH} $DRIVE_FOLDER"
echo " Backup Cmd : $backupCmd"
eval $backupCmd
if [ $? == 0 ] ; then
  echo " Backup Gitea Dump finished"
else
  echo " Backup Gitea Dump finished with errors"
fi

rm ${GITEA_BACKUP_PATH}
popd > /dev/null

echo
echo "---------------------------------------------------------"
echo "Gitea Backup Drive finished at $(date)"
echo "---------------------------------------------------------"
echo


