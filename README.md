# ocp-on-nuc
Use these instructions, adapted from [Grant Shipley's excellent
OpenShift Origin instructions](https://github.com/gshipley/installcentos),
to run OpenShift Container Platform on an Intel NUC.  The specific
hardware is an Intel NUC mini PC kit NUC6i7KYK (e.g. Skull Canyon).

![My Little NUC](my-intel-nuc.png)

| Feature | Description |
| :-----: | ----------- |
| CPU | Intel 2.6 GHz 4-Core i7 6700HQ |
| Memory | Crucial 32GB DDR4 2133 |
| Graphics | Intel Iris Pro Graphics 580 |
| SSD | Samsung 850 EVO - 500GB |

## Install RHEL
Install RHEL 7.5 using the minimal package set.  Create the following
mount points on the disk.  The sizes are scaled for the 500 GB SSD.

* /boot with 2 GiB
* /boot/efi with 1 GiB
* / with 358 GiB
* swap with 4 GiB

This leaves just over 100 GiB for the docker-vg volume group which
will be created later.  Make sure to set the root password and also
create an unprivileged user (with sudo privileges).

## Enable Stable Networking
I want to make this portable to any site for demonstrations with
the ability to have a predictable IP address for the NUC.  To do
that, I repurposed an old WiFi router to enable a LAN for my NUC
and my laptop and to provide a connection to the outside world.
These [instructions](linksys-openwrt-config.md) describe how I did
that.

## Edit the Configuration
Edit the `install.conf` and update the parameters as necessary.  At
a minimum, you'll need to update `RHSM_USER` and `RHSM_PASS` to
match your credentials for the [Red Hat Customer
Portal](https://access.redhat.com).  Optionally, you can asign the
`POOL_ID` to match one of your entitlements.

## Prepare the Server
Run the following script as root to prepare the server for installs.
This script registers the system and creates the docker-vg volume
group.

    ./prep-server.sh

The system will reboot once this script completes.

## Install OpenShift
Run the following script as root to install the server.  This script
installs prerequisites, runs the install, and then creates a cluster
admin user as well as an unprivileged user.

    ./install-server.sh

The following username/passwords are created:

* `admin/admin`
* `developer/developer`

## Create Persistent Volumes
Run the following script as root to create one hundred 10 GiB
persistent volumes.  The persistent volume directories are under
`/mnt/data`.

    ./create-pvs.sh

