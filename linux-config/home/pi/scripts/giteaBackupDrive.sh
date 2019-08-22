#! /bin/bash

#
# Banpi Script for Gitea Server Backup to GDrive
#

export PATH=$PATH:/usr/local/bin

TMP_PATH=/tmp-nolimit
FILE_BACKUP_PATH=/home/pi/scripts/fileBackupDrive.sh
GITEA_PATH=/usr/local/gitea
GITEA_COMMAND_PATH="$GITEA_PATH/gitea"
GITEA_CONFIG_FILE_PATH="${GITEA_PATH}/custom/conf/app.ini"
GITEA_BACKUP_PATH="${TMP_PATH}/gitea-dump.zip"
GIT_SERVER_PATH=/usr/local/gitea/gitea-repositories
DRIVE_FOLDER=gitea

# Git Repositories Backup
for gitRep in $(find $GIT_SERVER_PATH -maxdepth 2 -name '*.git' -type d) ; do
  #gitRepPath="${GIT_SERVER_PATH}/${gitRep}"
  echo " Found Git Repository : $gitRep"
  backupCmd="${FILE_BACKUP_PATH} $gitRep $DRIVE_FOLDER"
  echo "Backup Cmd : $backupCmd"
  eval $backupCmd
done

# Gitea App
pushd .
cd $TMP_PATH

rm -f gitea-dump-*
giteaBackupCmd="${GITEA_COMMAND_PATH} dump --tempdir ${TMP_PATH} --skip-repository -c ${GITEA_CONFIG_FILE_PATH}"
echo "Gitea Backup Cmd : ${giteaBackupCmd}"
eval $giteaBackupCmd
mv gitea-dump-*.zip $GITEA_BACKUP_PATH

backupCmd="${FILE_BACKUP_PATH} ${GITEA_BACKUP_PATH} $DRIVE_FOLDER"
echo "Backup Cmd : $backupCmd"
eval $backupCmd
rm ${GITEA_BACKUP_PATH}
popd

