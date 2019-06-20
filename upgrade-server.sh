#!/usr/bin/env bash

. $(dirname $0)/install.conf

subscription-manager refresh
yum -y update openshift-ansible

envsubst < inventory.orig > inventory.ini

oc login -u ${ADMIN_USER} -p ${ADMIN_PASS}
ansible-playbook -i inventory.ini /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/upgrades/v3_11/upgrade.yml
oc logout

