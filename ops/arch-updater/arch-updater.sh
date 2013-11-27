#!/bin/sh

UPDATER_LOG_FILE='/var/log/arch-updater.log'

if [ "`/usr/bin/id -u`" -ne 0 ]; then
    echo "Not running as root. Exiting..." 1>&2
    exit 1
else
    echo "Arch Updater started at $(date)" >> $UPDATER_LOG_FILE
    /usr/bin/pacman -Syyu --noconfirm >> $UPDATER_LOG_FILE 2>&1
fi

# TODO: Add Chrome updating from AUR.
