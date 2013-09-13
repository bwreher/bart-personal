#!/usr/bin/bash
# Takes a snapshot of the source directory, rotates old snapshots, then creates
# a new snapshot. To be used as a cronjob on the system.

# Exit conditions
DIRECTORY_MISSING_ERROR=1
PERMISSIONS_ERROR=2
NETWORK_SHARE_ERROR=3
SYSTEM_CMD_ERROR=4
MALFORMED_COMMAND=5
NO_FILES_ERROR=5
SNAPSHOT_COUNT_ERROR=6

usage() {
    cat <<EOF >&2
USAGE: $0 -l local-directory -r remote-host:/mnt -n 5 [FREQUENCY] SOURCE DESTINATION

Create a snapshot of SOURCE in DESTINATION with a given frequency. The snapshot
is stored in DESTINATION/SOURCE/FREQUENCY.N format, with N denoting the age of
the snapshot in days/weeks/months.

NOTE: This script does not run at the desired frequency. That should be left to
your cron daemon of choice.

Mandatory Flags:
  -l    Local path where network resource should be mounted
  -n    Number of snapshots at the given frequency to keep.
  -r    Network resource to mount (server:/mnt/directory)

Frequency Levels:
  -d    Run as daily snapshot.
  -w    Run as weekly snapshot.
  -m    Run as monthly snapshot.
EOF

exit $MALFORMED_COMMAND
}

flags='dhl:mn:r:w'

while getopts $flags flag
do
    case $flag in
    h) usage;;
    d) frequency="daily";;
    l) mount_destination=${OPTARG};;
    m) frequency="monthly";;
    n) num_snapshots=${OPTARG};;
    r) mount_source=${OPTARG};;
    w) frequency="weekly";;
    *) usage;;
    esac
done

SNAPSHOT_DIRECTORY=$BASH_ARGV
SOURCE_DIRECTORY=${*: -2:1}

#=/ Preconditions /=====================

# Check that there are a sufficient number of arguments.
if [ "$#" -lt 6 ]; then
    echo "Missing one or more arguments." 1>&2
    usage
fi

if [ "$num_snapshots" -lt 1 ]; then
    echo "Must have at least one snapshot." 1>&2
    exit $SNAPSHOT_COUNT_ERROR
fi

# Check that we are root. Necessary for mounting and ro snapshots.
if [ "`/usr/bin/id -u`" -ne 0 ]; then
    echo "Not running as root. Exiting..." 1>&2
    exit $PERMISSIONS_ERROR
fi

# Make sure the remote host is on.
# TODO: Add flag (or parse remote host flag) to find what to ping.
if [ "`/usr/bin/ping -q -c3 -w5 lisa > /dev/null`" ]; then
    echo "Cannot ping remote host. Exiting..." 1>&2
    exit $NETWORK_SHARE_ERROR
fi

# Attempt to mount the remote share locally.
if [ "`/usr/bin/mount -o remount,rw $mount_source $mount_destination`" ]; then
    echo "Cannot mount the snapshot destination: $mount_destination at $mount_source\r" 1>&2
    echo "Exiting..."
    exit $NETWORK_SHARE_ERROR
fi

# Give some time for the drives to spin-up on the remote host.
/usr/bin/sleep 30s

# Check that the snapshot source and destination paths exist.
if [ ! -d "$SOURCE_DIRECTORY" ] || [ ! -d "$SNAPSHOT_DIRECTORY" ]; then
    echo "Source: $SOURCE_DIRECTORY"
    echo "SS: $SNAPSHOT_DIRECTORY"
    echo "Directory does not exist. Exiting..." 1>&2
    exit $DIRECTORY_MISSING_ERROR
fi

# Count the number of files in the snapshot source. Exit if there's nothing to do.
if [ "`/usr/bin/ls -A $SOURCE_DIRECTORY | /usr/bin/wc -l`" -eq 0 ]; then
    echo "Source directory empty. Nothing to do here." 1>&2
    exit $NO_FILES_ERROR
fi


#=/ Snapshot Rotate /===================

# Remove the oldest snapshot.
rm -r $SNAPSHOT_DIRECTORY/$frequency.$((num_snapshots-1))

if [ "$num_snapshots" -gt 1 ]; then
    for i in $(seq $num_snapshots -1 2)
    do
        cp -a -p $SNAPSHOT_DIRECTORY/$frequency.$((i-2)) $SNAPSHOT_DIRECTORY/$frequency.$((i-1))
    done

    # Make room for the new snapshot sync.
    rm -r $SNAPSHOT_DIRECTORY/$frequency.0
fi


#=/ Create New Snapshot /===============
/usr/bin/rsync -AaHXv --exclude '*\.cache*' --exclude '*\.config*' $SOURCE_DIRECTORY $SNAPSHOT_DIRECTORY/$frequency.0
exit 0
