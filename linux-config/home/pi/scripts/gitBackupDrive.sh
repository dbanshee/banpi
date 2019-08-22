#! /bin/bash

GIT_SERVER_PATH=/usr/local/git-server
TMP_PATH=/tmp-nolimit
BACKUP_PATH="$TMP_PATH/git-backup"
CURRENT_BACKUP_PATH="${BACKUP_PATH}/current"
LAST_BACKUP_PATH="${BACKUP_PATH}/last"

echo "Git Backup Drive - $(date)"
echo "  Git Server Path     : ${GIT_SERVER_PATH}"
echo "  Temp Path           : ${TMP_PATH}"

mkdir -p $CURRENT_BACKUP_PATH
mkdir -p $LAST_BACKUP_PATH

# GDrive
gDriveGitFolderId=$(gdrive list --query "name = 'git'" --no-header | cut -d' ' -f1)
echo "  Grive Git Folder Id : $gDriveGitFolderId"
echo

#
for gitRepPath in $(find $GIT_SERVER_PATH -maxdepth 2 -name '*.git' -type d) ; do
  echo " Found Git Repository : $gitRepPath"
  repName=$(basename $gitRepPath)

  backupFileName="${repName}.tgz"
  backupPath="${CURRENT_BACKUP_PATH}/${backupFileName}"
  backupPathCompleted="${LAST_BACKUP_PATH}/${backupFileName}"

  # Generate tgz backup
  tarCmd="tar -c ${gitRepPath} | bzip2 > $backupPath" 
  echo " Backup Command : ${tarCmd}"
  eval $tarCmd 
  echo " Backup File Generated : ${backupPath}"

  # Check last backup
  lastBackupFileId=$(gdrive list --query "name = '${backupFileName}' and '${gDriveGitFolderId}' in parents" --no-header | cut -d' ' -f1)
  if [ ! -z "${lastBackupFileId}" ] ; then
     echo " Found previous Backup on GDrive with Id : ${lastBackupFileId}"
     downLastBackCmd="gdrive download --force --no-progress --path $LAST_BACKUP_PATH  $lastBackupFileId"
     echo " Grive Download Prev Backup Cmd : $downLastBackCmd"
     eval $downLastBackCmd

     md5Backup="$(md5sum $backupPath | cut -d' ' -f1)"
     md5LastBackup="$(md5sum $backupPathCompleted | cut -d' ' -f1)"

     echo " MD5 Current Backup : $md5Backup"
     echo " MD5 Last    Backup : $md5LastBackup"

     if [ "$md5Backup" != "$md5LastBackup" ] ; then
       echo " Backup has changes. Updating."
       updateBackupCmd="gdrive update --no-progress -p $lastBackupFileId $backupPath"
       echo " Update Backup Cmd : $updateBackupCmd"
       eval $updateBackupCmd
     else
       echo " Backup has not changes. Skipped."
     fi
  else 
    echo " Not exists previous Backup" 
    uploadBackupCmd="gdrive upload --no-progress -p ${gDriveGitFolderId} $backupPath"
    echo " Upload Backup Cmd : $uploadBackupCmd"
    eval $uploadBackupCmd
  fi   

  echo
done

echo "Deleting Temp Backup Path : ${BACKUP_PATH}"
rm -rf $BACKUP_PATH 
