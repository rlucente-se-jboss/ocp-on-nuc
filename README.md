# ocp-on-nuc
Use these instructions, adapted from [Grant Shipley's excellent
OpenShift Origin instructions](https://github.com/gshipley/installcentos),
to run OpenShift Container Platform on an Intel NUC.  The specific
hardware is an Intel NUC mini PC kit NUC6i7KYK (e.g. Skull Canyon)
with the following configuration:

<p align="center">
<img src="my-intel-nuc.png" alt="My Little NUC">
</p>

<table align="center">
<tr><th>Feature</th><th>Description</th></tr>
<tr><td>CPU</td><td>Intel 2.6 GHz 4-Core i7 6700HQ</td></tr>
<tr><td>Memory</td><td>Crucial 32GB DDR4 2133</td></tr>
<tr><td>Graphics</td><td>Intel Iris Pro Graphics 580</td></tr>
<tr><td>SSD</td><td>Samsung 850 EVO - 500GB</td></tr>
</table>

## Install RHEL
Install RHEL 7.5 using the minimal package set.  Create the following
mount points on the disk:

* /boot with 2 GiB
* / with 394 GiB
* swap with 4 GiB

This leaves about 100 GiB for the docker-vg volume group which will
be created later.  Make sure to set the root password and also
create an unprivileged user (with sudo privileges).

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

