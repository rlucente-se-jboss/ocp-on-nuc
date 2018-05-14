I started with stock Linksys WRT54G v2
Go to https://openwrt.org and download the appropriate device files
openwrt-wrt54g-squashfs.bin
openwrt-brcm47xx-squashfs.trx

Reflash the stock firmware with openwrt-wrt54g-squashfs.bin
Flash the openwrt-brcm47xxx-squashfs.trx update

Now have OpenWRT running on Linksys WRT54G v2

The following is adapted from https://wiki.openwrt.org/doc/recipes/routedclient

After initial startup, open the browser to http://192.168.1.1/
Login as root with no password
Select System in the top tabs and Administration in the second row
set the root password, set the Dropbear interface to lan, and add your public ssh key
Click Save & Apply button at the bottom

ssh root@192.168.1.1

sed -i ’s/192.168.1./10.10.10./g’ /etc/config/firewall
sed -i ’s/192.168.1./10.10.10./g’ /etc/config/network
sed -i ’s/192.168.1./10.10.10./g’ /etc/init.d/netconfig
sed -i ’s/192.168.1./10.10.10./g’ /etc/preinit
sed -i ’s/192.168.1./10.10.10./g’ /etc/rc.d/S05netconfig
reboot; exit

Disconnect LAN network cable and wait for router to restart

When power LED is solid green, reconnect the LAN network cable

ssh root@10.10.10.1

uci del wireless.@wifi-device[0].disabled
uci del wireless.@wifi-iface[0].network
uci set wireless.@wifi-iface[0].mode=sta
uci commit wireless
wifi

after the wifi command you’ll see:

Error for wireless request "Set Power Management" (8B2C) :
    SET failed on device wlan0 ; Operation not supported.

because the device does not support power management.

Issue the command

iwlist scan

which will show nearby WiFi networks with public ssid.  This shows that the WiFi radio is now enabled.  If you see:

Device or resource busy for the wlan0 device, then type

killall -9 wpa_supplicant
iwlist scan

Edit /etc/config/network so it contains the following

...
#### WAN configuration
config interface        wan
        option proto    dhcp

Make sure there is no ifname option under the wan interface

The contents of /etc/config/wireless should be

config 'wifi-device' 'radio0'
        option 'type' 'mac80211'
        option 'channel' '11'
        option 'macaddr' '00:0c:41:36:38:b9'
        option 'hwmode' '11g'

config 'wifi-iface'
        option 'device' 'radio0'
        option 'network' 'wan'
        option 'mode' 'sta'
        option 'ssid' 'helios'
        option 'encryption' 'psk2'
        option 'key' 'Youre a nosy bastard arent you'

Finally, type

ifup wan
wifi

And that’s it.  Edit the wifi-iface section in /etc/config/wireless if using a different wifi network and then issue

ifup wan
wifi

