#!/usr/bin/env bash

. $(dirname $0)/install.conf

envsubst < inventory.orig > inventory.ini

oc login -u ${ADMIN_USER} -p ${ADMIN_PASS}
ansible-playbook -i inventory.ini /usr/share/ansible/openshift-ansible/playbooks/openshift-logging/config.yml
oc logout

