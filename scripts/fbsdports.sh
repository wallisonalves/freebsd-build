#!/bin/sh
#
# Copyright (c) 2015, Angelescu Ovidiu All rights reserved.
#
# See COPYING for licence terms.
#
# $FreeBSD$
# $Id: fbsdports.sh,v 1.7 Thu Jun 23 10:04:31 AST 2015 Angelescu Ovidiu


if [ -z "${LOGFILE:-}" ]; then
    echo "This script can't run standalone."
    echo "Please use launch.sh to execute it."
    exit 1
fi

if [ ! -f "/usr/local/bin/git" ]; then
  echo "Install Git to fetch pkg from GitHub"
  exit 1
fi


PKGFILE=${PKGFILE:-/tmp/${PACK_PROFILE}-freebsd};
PKGFILED=/tmp/${PACK_PROFILE}-freebsd-deps

#if [ ! -f ${PKGFILE} ]; then
 # return
#fi
touch ${PKGFILE}

build_ports_list()
{
# Search main file package for include dependecies
# and build an depends file ( depends )
awk '/^freebsd_deps/,/^"""/' ${LOCALDIR}/packages/${PACK_PROFILE} | grep -v '"""' | grep -v '#' > /tmp/${PACK_PROFILE}-fdepends

# If exist an old .packages file removes it
if [ -f /tmp/${PACK_PROFILE}-freebsd ] ; then
  rm -f /tmp/${PACK_PROFILE}-freebsd
fi

# Reads depends file and search for packages entries in each file from depends
# list, then append all packages found in freebsd file
while read pkgs ; do
awk '/^packages/,/^"""/' ${LOCALDIR}/packages/freebsd.d/$pkgs  >> /tmp/${PACK_PROFILE}-fpackage
done < /tmp/${PACK_PROFILE}-fdepends

# Removes """ and # from temporary package file
cat /tmp/${PACK_PROFILE}-fpackage | grep -v '"""' | grep -v '#' > /tmp/${PACK_PROFILE}-freebsd

# Removes temporary files
if [ -f /tmp/${PACK_PROFILE}-fpackage ] ; then
  rm -f /tmp/${PACK_PROFILE}-fpackage
  rm -f /tmp/${PACK_PROFILE}-fdepends
fi
}


build_ports_depends()
{
PKGFILED=/tmp/${PACK_PROFILE}-freebsd-deps

if [ -f ${PKGFILED} ]; then
    rm -f $PKGFILED
fi

### Add freebsd ports depends to $PKGFILE

if [ -d $BASEDIR/ports ]; then
    rm -Rf $BASEDIR/ports
fi

if [ ! -f "/usr/local/bin/git" ]; then
  echo "Install Git to fetch pkg from GitHub"
  exit 1
fi
echo "# Downloading freebsd ports from GitHub #"
git clone https://github.com/wallisonalves/ports.git ${BASEDIR}/ports   >/dev/null 2>&1
cp -Rf $BASEDIR/ports/ $BASEDIR/usr/ports

echo "Building ports depends."
rm -Rf  ${BASEDIR}/dist/ports/.git

while read gport ; do
    for port in $(find ${BASEDIR}/ports/ -type d -depth 2 -name $gport )  ; do
        cd $port
        cat Makefile| grep DEPENDS |sed -e 's/kde4/kde/g'|sed -e 's/glib2.0/libglib2.0/g'| tr '\' ' '| grep PORTSDIR |cut -d : -f 2| cut -d / -f 2 >> ${PKGFILED}
    done
done < $PKGFILE
}

install_ports_depends()
{
PKGFILED=/tmp/${PACK_PROFILE}-freebsd-deps
export PKGFILED

# cp ports depends file for fetching ports depends
cp $PKGFILED ${BASEDIR}/mnt

# prepares addpkg.sh script to add packages under chroot
PLOGFILED="$BASEDIR/mnt/.log_dpkginstall"

cat > ${BASEDIR}/mnt/addpkg.sh << "EOF"
#!/bin/sh 

# pkg install part
cd /mnt
PLOGFILED=".log_dpkginstall"
pkgfile="${PACK_PROFILE}-freebsd-deps"
pkgaddcmd="pkg install -y"

while read pkgc; do
    if [ -n "${pkgc}" ] ; then
    echo "Installing package $pkgc"
    echo "Running $pkgaddcmd ${pkgc}" >> ${PLOGFILED} 2>&1
    $pkgaddcmd $pkgc >> ${PLOGFILED} 2>&1
    fi
done < $pkgfile

rm addpkg.sh
rm $pkgfile
EOF

# run addpkg.sh in chroot to add packages
chrootcmd="chroot ${BASEDIR} sh /mnt/addpkg.sh"
$chrootcmd

mv ${PLOGFILED} ${MAKEOBJDIRPREFIX}/${LOCALDIR}

rm -f ${BASEDIR}/mnt/*
}

build_ports()
{
# build freebsd ports 
cp -af ${PKGFILE} ${BASEDIR}/mnt
PLOGFILE=".log_portsinstall"

cat > ${BASEDIR}/mnt/portsbuild.sh << "EOF"
#!/bin/sh 

pkgfile="${PACK_PROFILE}-freebsd"
FORCE_PKG_REGISTER=true
export FORCE_PKG_REGISTER
PLOGFILE=".log_portsinstall"

cd /mnt

while read pkgc; do
    if [ -n "${pkgc}" ] ; then
        echo "Building and installing port $pkgc"
        # builds freebsd ports in chroot
        for port in $(find /ports/ -type d -depth 2 -name ${pkgc})  ; do
        cd /usr$port
        make >> /mnt/${PLOGFILE} 2>&1 
        make install >> /mnt/${PLOGFILE} 2>&1 
        done
    fi
done < $pkgfile

rm -f /mnt/portsbuild.sh
rm -f /mnt/$pkgfile

EOF


# Build and install freebsd ports in chroot 
chrootcmd="chroot ${BASEDIR} sh /mnt/portsbuild.sh"
$chrootcmd

rm -Rf ${BASEDIR}/ports

# save logfile where should be
mv ${BASEDIR}/mnt/${PLOGFILE} ${MAKEOBJDIRPREFIX}/${LOCALDIR}
}

if ! ${USE_JAILS} ; then
    if [ -z "$(mount | grep ${BASEDIR}/var/run)" ]; then
        mount_nullfs /var/run ${BASEDIR}/var/run
    fi
fi
cp -af /etc/resolv.conf ${BASEDIR}/etc

build_ports_list
build_ports_depends
if [ -s ${PKGFILED} ]; then
    install_ports_depends
fi
build_ports

# umount /var/run if not using jails
if ! ${USE_JAILS} ; then
    if [ -n "$(mount | grep ${BASEDIR}/var/run)" ]; then
        umount ${BASEDIR}/var/run
    fi
fi
rm ${BASEDIR}/etc/resolv.conf
