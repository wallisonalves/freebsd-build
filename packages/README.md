A $flavour means to be a desktop environmnet such 
as: KDE, Gnome, Mate, XFCE or even nox ( no X which means pure freebsd freebsd configured)

 freebsd-build/packages directory structure:
1) a $flavour file 
2) packages.d subdir for freebsd packages includes from deps section of 
freebsd-build/packages/$flavour file 
3) freebsd.d subdir for freebsd ports/packages includes  from 
freebsd_deps section of freebsd-build/packages/$flavour file
4) packages.cfg subdir for freebsd packages that needs special configuration 
after installing 

1)
Please don't change $flavour file structure because build scripts won't work
$flavour file is structured as :

desc = """
brief description of $flavour
"""
deps = """
$flavour depends/includes from packages.d files
"""
packages = """
unused now
"""
freebsd_deps="""
$flavour depends/includes from freebsd.d freebsd files/ports
"""

2) packages.d subdir contains files structured by some criteria such 
as: internet, print, office , sound-video, graphic, DE (kDE files , mate files ..), xorg
each file from packages.d is structured as:
