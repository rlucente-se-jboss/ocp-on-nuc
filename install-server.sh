#!/usr/bin/env bash

. $(dirname $0)/install.conf

yum -y install openshift-ansible docker-1.13.1 atomic

MYHOSTNAME=
if [ -z "$(hostname | grep localhost)" ]
then
    MYHOSTNAME=$(hostname)
fi

cat <<EOD > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
${IP}       $MYHOSTNAME console console.${DOMAIN}
EOD

cat <<EOF > /etc/sysconfig/docker-storage-setup
VG=docker-vg
EOF

docker-storage-setup

systemctl restart docker
systemctl enable docker

if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -q -f ~/.ssh/id_rsa -N ""
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    ssh -o StrictHostKeyChecking=no root@$IP "pwd" < /dev/null
fi

envsubst < inventory.orig > inventory.ini
mkdir -p /etc/origin/master
touch /etc/origin/master/htpasswd

echo
echo "Pause here so you can load the docker images from separate storage"
echo
echo "Press ENTER to continue ..."
read answer

ansible-playbook -i inventory.ini /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i inventory.ini /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml

htpasswd -b /etc/origin/master/htpasswd ${ADMIN_USER} ${ADMIN_PASS}
oc adm policy add-cluster-role-to-user cluster-admin ${ADMIN_USER}

htpasswd -b /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}

echo "******"
echo "* Your console is https://console.$DOMAIN:$API_PORT"
echo "*"
echo "* Administrative username is $ADMIN_USER "
echo "* Administrative password is $ADMIN_PASS "
echo "*"
echo "* Unprivileged username is $USERNAME "
echo "* Unprivileged password is $PASSWORD "
echo "*"
echo "* Login using:"
echo "*"
echo "$ oc login -u ${ADMIN_USER} -p ${ADMIN_PASS} console.$DOMAIN:$API_PORT"
echo "******"

