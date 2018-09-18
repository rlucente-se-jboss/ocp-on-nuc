#!/bin/bash

. $(dirname $0)/install.conf

for i in {0..99}
do
	DIRNAME=$(printf "vol%02d" $i)
	mkdir -p /mnt/data/$DIRNAME
        chmod a+rwx /mnt/data/$DIRNAME
	chcon -Rt svirt_sandbox_file_t /mnt/data/$DIRNAME
done

sleep 5
oc login console.$DOMAIN:$API_PORT -u $ADMIN_USER -p $ADMIN_PASS

for i in {0..99}
do
	DIRNAME=$(printf "vol%02d" $i)
	sed -i "s/name: vol..*/name: $DIRNAME/g" vol.yaml
	sed -i "s/path: \/mnt\/data\/vol..*/path: \/mnt\/data\/$DIRNAME/g" vol.yaml
	oc create -f vol.yaml
	echo "created volume $i"
done

# fix issue where requested ose-recycler image tag is wrong
docker pull \
    registry.access.redhat.com/openshift3/ose-recycler:$RECYCLE_VERSION
docker image tag \
    registry.access.redhat.com/openshift3/ose-recycler:$RECYCLE_VERSION \
    registry.access.redhat.com/openshift3/ose-recycler:v1.10.0

