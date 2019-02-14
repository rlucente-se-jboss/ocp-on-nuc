#!/usr/bin/env bash

. $(dirname $0)/install.conf

# configure subscription repositories
subscription-manager register --username=$RHSM_USER --password=$RHSM_PASS \
    || exit 1

if [ -z "$POOL_ID" ]
then
    POOL_ID=$(subscription-manager list --available | \
    grep 'Subscription Name\|Pool ID' | \
    grep -A1 'Employee SKU' | \
    grep 'Pool ID' | awk '{print $NF; exit}')
fi

subscription-manager attach --pool=$POOL_ID
subscription-manager repos --disable='*'
subscription-manager repos \
    --enable=rhel-7-server-rpms \
    --enable=rhel-7-server-extras-rpms \
    --enable=rhel-7-server-ose-3.11-rpms \
    --enable=rhel-7-server-ansible-2.6-rpms

# update the system
yum -y update

# configure a separate volume group for docker (e.g. docker-vg)
DISK=$(parted -l | grep Disk | awk '{print $2; exit}' | cut -d: -f1)
FREESPACE=$(parted $DISK print free | grep 'Free Space' | tail -1)
START=$(echo $FREESPACE | awk '{print $1}')
END=$(echo $FREESPACE | awk '{print $2}')
parted $DISK mkpart primary $START $END

PARTNUM=$(parted $DISK print | sort -n | tail -1 | awk '{print $1}')
parted $DISK set $PARTNUM lvm on

pvcreate ${DISK}${PARTNUM}
vgcreate docker-vg ${DISK}${PARTNUM}

# limit hang on shutdown to just over a minute
sed -i 's/^#\(DefaultTimeoutStopSec\)=90s/\1=30s/g' /etc/systemd/system.conf

yum -y clean all
systemctl reboot

