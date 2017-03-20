#!/bin/sh

# enable cups in rc.conf
echo 'cupsd_enable="YES"' >> /etc/rc.conf
# disable freebsd lpd in rc.conf
echo 'lpd_enable="NO"' >> /etc/rc.conf
