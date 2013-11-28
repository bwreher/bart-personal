#!/bin/sh

UPDATER_LOG_FILE='/var/log/arch-updater.log'
CHROME_AUR_TARBALL='https://aur.archlinux.org/packages/go/google-chrome-beta/google-chrome-beta.tar.gz'

if [ "`/usr/bin/id -u`" -ne 0 ]; then
    echo "Not running as root. Exiting..." 1>&2
    exit 1
else
    echo "Arch Updater started at $(date)" >> $UPDATER_LOG_FILE
    /usr/bin/pacman -Syyu --noconfirm >> $UPDATER_LOG_FILE 2>&1
fi

# TODO: Add Chrome updating from AUR.
INSTALLED_CHROME_VERSION="`pacman -Qm | grep -i google-chrome-beta | awk -F" " '{ print $2 }'`"
CURRENT_CHROME_VERSION=`curl -s https://dl.google.com/linux/chrome/rpm/stable/x86_64/repodata/other.xml.gz | gzip -df | awk -F\" '/pkgid/{ sub(".*-","",$4); print $4": "$10 }' | grep -i 'beta' | awk -F" " '{ print $2 }'`

echo "Chrome (beta) installed version: $INSTALLED_CHROME_VERSION" >> $UPDATER_LOG_FILE
echo "Found Chrome (beta) version: $CURRENT_CHROME_VERSION" >> $UPDATER_LOG_FILE

if [ "`echo $INSTALLED_CHROME_VERSION | sed 's/\(\.|-.*\)//g'`" != "`echo $INSTALLED_CHROME_VERSION | sed 's/\(\.|-.*\)//g'`" ]; then
    echo "New version of Chrome available: $CURRENT_CHROME_VERSION will replace $INSTALLED_CHROME_VERSION" >> $UPDATER_LOG_FILE
else
    echo "Chrome is up to date." >> $UPDATER_LOG_FILE
    exit 0
fi

exit 0
