#!/usr/bin/env bash

. $(dirname $0)/install.conf

# configure subscription repositories
subscription-manager register --username=$RHN_USER --password=$RHN_PASS

if [ -z "$POOL_ID" ]
then
    POOL_ID=$(subscription-manager list --available | \
        grep 'Subscription Name\|Pool ID' | \
        grep -A1 'OpenShift Employee Subscription' | \
        grep 'Pool ID' | awk '{print $NF}')
fi

subscription-manager attach --pool=$POOL_ID
subscription-manager repos --disable='*'
subscription-manager repos \
    --enable=rhel-7-server-rpms \
    --enable=rhel-7-server-extras-rpms \
    --enable=rhel-7-server-ose-3.9-rpms \
    --enable=rhel-7-fast-datapath-rpms \
    --enable=rhel-7-server-ansible-2.4-rpms

# install needed packages and update the system
yum -y install \
    wget git net-tools bind-utils iptables-services bridge-utils \
    bash-completion kexec-tools sos psacct
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

yum -y clean all
systemctl reboot

