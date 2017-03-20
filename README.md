FreeBSD-Build
=============

# Please visit [WIKI](https://github.com/wallisonalves/freebsd-build/wiki) and follow the instructions!

## Introduction
__FreeBSD build toolkit__ is directly derived from __FreeSBIE toolkit__, but most of the code changed.The __freebsd-build__ is been designed to allow developers to building both, __i386__ and __amd64__ architectures on __amd64__ architectures. The __freebsd-build__ to can build __FreeBSD-LiveCD/DVD/USB__ on __FreeBSD__.

## Installing FreeBSD-Build
First, you need to install __git__, __xorriso__, __rsync__, __grub2-pcbsd__ as _root_ user using _su_ or _sudo_.
```
  pkg install git xorriso rsync grub2-pcbsd
```
Second thing is to download __FreeBSD Build Toolkit__.
```
  git clone https://github.com/wallisonalves/freebsd-build.git
```

## Configuring the system
Have a look in _freebsd-build/conf/freebsd.defaults.conf_ - you will notice very important lines below:
```
  NO_BUILDWORLD=YES
  NO_BUILDKERNEL=YES
```

Comment out these two lines the first time you run the building process for each architecture. The next time you run it, 
you can uncomment them - this will save you quite some build time (you simply do not need to rebuild your kernel and world every time 
unless you've committed significant changes to them).

If you would like avoid compiling the kernel and world, you can fetch the FreeBSD files to build from. This is a faster and cleaner way. 
To enable this, make sure that your  _freebsd-build/conf/freebsd.defaults.conf_ has the following lines enabled:
```
  FETCH_FREEBSDBASE=${FETCH_FREEBSDBASE:-"YES"}
  FETCH_FREEBSDKERNEL=${FETCH_FREEBSDKERNEL:-"YES"}
```
By default __freebsd-build__ is configured to work out of the box.

## Building the system

Now that the whole configuration is done, all you need to push the button:
```
  cd freebsd-build/mkscripts
```
```
  ls
```

Now you will need to execute one of the following scripts in this directory.  To build __mini__ for __amd64__:
```
  ./make_mini_amd64_iso
```
or for __i386__
```
  ./make_mini_i386_iso
```

This will build the whole system and the __iso__ image.

## Troubleshooting
Logs are stored in:
```
  /usr/obj/fblogs/
```

## Accessing the images
All resulting images will be stored in:
```
  /usr/obj/
```
## Cleaning up the build environment
Once the process is finished, it's a good idea to clean up the system after building.
The example below shows the script to clean for __MINI__ on __amd64__. 
Now all we need to do is clean up after building (remember you can only build back after
issuing the following commands):
```
  cd freebsd-build/clscripts
```
```
  ./clean_mini_amd64
```
```
  ./clean_mini_i386
```

# Finished!
