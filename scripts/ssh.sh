#! /bin/bash

DEST=`echo "" | dmenu -p "SSH" -nb "#000" -nf "#fff" -sb "#fff" -sf "#000"`
if [ x$DEST != x ]
then
    eval `cat ~/.ssh/environment-trantor`
    urxvtc -e ssh $DEST
fi