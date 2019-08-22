#! /bin/bash

SCREEN_NAME=banpi

function finish () {
  echo "Caught Signal ..."
  screen -d
  exit 1
}
#trap finish EXIT SIGQUIT SIGABRT SIGKILL SIGTERM

screen -S $SCREEN_NAME -Q select .
if [ $? == 1 ] ; then 
  echo "Opening new screen $SCREEN_NAME"
  screen -S $SCREEN_NAME
else
  echo "Attaching to screen $SCREEN_NAME"
  screen -rx $SCREEN_NAME
fi
