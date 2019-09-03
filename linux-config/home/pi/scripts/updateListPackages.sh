#! /bin/bash


INPUT_FILE=""
if [ $# == 1 ] ; then
  INPUT_FILE=$1
fi


zgrep -h Commandline /var/log/apt/history.log* | cut -d':' -f2 | sort > /tmp/updateListPackages.tmp
cat ${INPUT_FILE} /tmp/updateListPackages.tmp | sort | uniq
