# Overview
One of the needs is to have a stable IP address for my OCP instance
regardless of where I'm running it.  This makes it portable across
multiple demo environments.  My goal is to provide connectivity to
the broader public internet while enabling my laptop to easily
connect to my OCP instance at a stable IP address.

![Old But Reliable Linksys Router](linksys-router.png)

# Update the Router Firmware
The following instructions to update the router firmware are adapted
from the [OpenWRT wiki](https://wiki.openwrt.org/toh/linksys/wrt54g#installing_openwrt).

I have an an old Linksys WRT54G v2 WiFi router to repurpose for
this.  To customize it and to bring the firmware to a more recent
release, reimage the router to use [OpenWRT](https://openwrt.org).
Specifically, put the following software on the WRT54G router:

* openwrt-wrt54g-squashfs.bin
* openwrt-brcm47xx-squashfs.trx

## Reflash to OpenWRT
Reflash the manufacturer stock firmware with the
openwrt-wrt54g-squashfs.bin file.

## Set Authentication Credentials
Reboot the router and log in via the [default LUCI web interface](http://192.168.1.1/).
For login credentials, use `root` with no password.  In the web
interface, select `System` in the top row of tabs and `Administration`
in the second row.  Set the `root` password, set the Dropbear
interface to `lan`, and also add a public SSH key to enable easier
login via SSH.  Click the `Save & Apply` button at the bottom of
the web page.

## Update Broadcom SoC Firmware
Download the openwrt-brcm47xxx-squashfs.trx.  On the LUCI web site,
select `System -> Flash firmware` and select the file you downloaded.

The Linksys WRT54G v2 router will now be running OpenWRT 10.03.1
with the Broadcom 47xxx SoC firmware.

# Configure WiFi Masquerading
The following is adapted from the OpenWRT wiki for a [routed client](https://wiki.openwrt.org/doc/recipes/routedclient).  The WiFi will act as a WAN adapter to the multiple LAN ports on the router.

## Change the default IP Address
Set the LAN IP address to something that does not conflict with the wireless network you're using.  Connect a laptop to one of the router LAN ports and use the following commands within a terminal window.

    ssh root@192.168.1.1
    sed -i ’s/192.168.1./10.123.123./g’ /etc/config/firewall
    sed -i ’s/192.168.1./10.123.123./g’ /etc/config/network
    sed -i ’s/192.168.1./10.123.123./g’ /etc/init.d/netconfig
    sed -i ’s/192.168.1./10.123.123./g’ /etc/preinit
    sed -i ’s/192.168.1./10.123.123./g’ /etc/rc.d/S05netconfig
    reboot; exit

Disconnect the LAN network cable since the IP addresses are updated
and wait for router to restart.  When power LED is solid green,
reconnect the LAN network cable

## Enable the WiFi
Use the following commands to enable the WiFi device.

    ssh root@10.123.123.1
    uci del wireless.@wifi-device[0].disabled
    uci del wireless.@wifi-iface[0].network
    uci set wireless.@wifi-iface[0].mode=sta
    uci commit wireless
    wifi

After you issue the `wifi` command to enable the wireless interface, you'll see the error message:

    Error for wireless request "Set Power Management" (8B2C) :
        SET failed on device wlan0 ; Operation not supported.

This error occurs because the WRT54G device does not support power
management.

## Test the WiFi radio
Issue the following command to scan for nearby WiFi networks.

    iwlist scan

This shows that the WiFi radio is now enabled.  If you see `Device or resource busy` for the wlan0 device, then type:

    killall -9 wpa_supplicant
    iwlist scan

## Configure Masquerading
Edit /etc/config/network so the WAN configuration at the bottom of the file matches the following.

    ...
    #### WAN configuration
    config interface        wan
            option proto    dhcp

Make sure there is no `ifname` option under the wan interface.

The contents of /etc/config/wireless should be:

    config 'wifi-device' 'radio0'
            option 'type' 'mac80211'
            option 'channel' '11'
            option 'macaddr' '00:0c:41:36:38:b9'
            option 'hwmode' '11g'
    
    config 'wifi-iface'
            option 'device' 'radio0'
            option 'network' 'wan'
            option 'mode' 'sta'
            option 'ssid' 'UPSTREAM-WIFI-SSID'
            option 'encryption' 'psk2'
            option 'key' 'UPSTREAM-WIFI-PASSWORD'

Obviously, the `macaddr` should match the MAC address for your
router's WiFi device and the `ssid` and `key` should match the
upstream WiFi network.

Finally, type the following to enable the WiFi masquerading.

    ifup wan
    wifi

# Using Alternative WiFi Network
To change to a different WiFi network, simply edit the `wifi-iface`
section in /etc/config/wireless and then issue the commands:

    ifup wan
    wifi

