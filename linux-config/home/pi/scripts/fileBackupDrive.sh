#! /bin/bash

#
# Banpi Script for File Server Backup to GDrive
#
echo "PATH : $PATH"
#which gdrive > /dev/null
#if [ $? == 1 ] ; then
#  echo "Command gdrive in path is required. Abort."
#  exit -1
#fi

nArgs=$#
if [ $nArgs == 2 ] ; then
  FILE_PATH=$1
  DRIVE_FOLDER=$2
else
  echo "Invalid arguments"
  echo "Usage : fileBackupDrive.sh [<file-path> <gdrive-folder-name>]"
  exit -1
fi


TMP_PATH=/tmp-nolimit
BACKUP_PATH="$TMP_PATH/file-backup"
CURRENT_BACKUP_PATH="${BACKUP_PATH}/current"
LAST_BACKUP_PATH="${BACKUP_PATH}/last"

echo "File Backup Drive - $(date)"
echo "  File Path           : ${FILE_PATH}"
echo "  GDrive Folder       : ${DRIVE_FOLDER}"
echo "  Temp Path           : ${TMP_PATH}"

mkdir -p $CURRENT_BACKUP_PATH
mkdir -p $LAST_BACKUP_PATH

# GDrive
gDriveGitFolderId=$(gdrive list --query "name = '$DRIVE_FOLDER'" --no-header | cut -d' ' -f1)
if [ -z $gDriveGitFolderId ] ; then
  echo "  Grive Git Folder not exists."
  exit -1
else
  echo "  Grive Git Folder Id : $gDriveGitFolderId"
fi
echo

fileName=$(basename $FILE_PATH)

backupFileName="${fileName}.tgz"
backupPath="${CURRENT_BACKUP_PATH}/${backupFileName}"
backupPathCompleted="${LAST_BACKUP_PATH}/${backupFileName}"

# Generate tgz backup
tarCmd="tar -c ${FILE_PATH} | bzip2 > $backupPath" 
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
     updateBackupCmd="gdrive update --no-progress $lastBackupFileId $backupPath"
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

echo "Deleting Temp Backup Path : ${BACKUP_PATH}"
rm -rf $BACKUP_PATH 
