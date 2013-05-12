# Copyright 2006-2011 Edoceo, Inc.
# :mode=shellscript:

EAPI="4"

inherit eutils

# Required Variables
DESCRIPTION="Edoceo Praxis Tools"
HOMEPAGE="http://praxis.edoceo.com/"
IUSE=""
KEYWORDS="amd64 x86"
LICENSE="MIT"
SLOT="0"
SRC_URI="http://cdn.edoceo.com/praxis/$PF.tgz"
RESTRICT="mirror"



#
# Functions
#
pkg_setup()
{
    enewgroup edoceo
    enewuser atom 65 /bin/bash /opt/edoceo edoceo
}

# Extract this tarball to the ${WORKDIR}
# Called during unpack|merge
# src_unpack()
# {
#     # echo "A=${A}"
#     # echo "CATEGORY=${CATEGORY}"
#     # echo "D=${D}"
#     # echo "FILESDIR=${FILESDIR}"
#     # echo "P=${P}"
#     # echo "PF=${PF}"
#     # echo "PN=${PN}"
#     # echo "PR=${PR}"
#     # echo "PV=${PV}"
#     # echo "PVR=${PVR}"
#     # echo "ROOT=${ROOT}"
#     # echo "S=${S}"
#     # echo "T=${T}"
#     # echo "WORKDIR=${WORKDIR}"
#     # echo "cwd=" $(pwd)
#
#     unpack ${A}
#
#     # cd "${S}"
#     # ls -alh
#     # sed -i '/^AWK/s:nawk:gawk:' Makefile #214865
#     # dnsmasq on FreeBSD wants the config file in a silly location, this fixes
#     # epatch "${FILESDIR}/${P}-fbsd-config.patch"
# }

# What to do here?
# pkg_config()
# {
#     ebegin "pkg_config($arch)"
#
#     einfo "Do you want to install the Praxis Binary Host? (Y/n)"
#     read res
#     case $res in
#     Y|y)
#             # echo -e "\n# Added by edoceo/atom" >> /etc/make.conf
#             # echo "PORTAGE_BINHOST=http://cdn.edoceo.com/praxis/x86_$arch" >> /etc/make.conf
#             ;;
#     esac
#     return
# }

# What to do here?
# pkg_prerm()
# {
#     # ewarn "pkg_prerm()"
#     return
# }

# What to do here?
# Right after Merged with $ROOT
pkg_postinst()
{
    # https://carbon.edoceo.com/svn/praxis-base
    arch=$(awk '/flags.+lm/ { print "x64" }' /proc/cpuinfo | tail -n1)
    ewarn "Detected Arch: $arch"
    case "$arch" in
    "x32")
        echo "Use Aluminium or Nitrogen"
        arch_profile="aluminium"
        ;;
    "x64")
        echo "Use Silicon or Neon"
        arch_profile="silicon"
        ;;
    esac

    zgrep -q CONFIG_SYSVIPC=y /proc/config.gz     || ewarn "Kernel is missing: CONFIG_SYSVIPC=y"
    zgrep -q CONFIG_USB_SUSPEND=y /proc/config.gz || ewarn "Kernel is missing: CONFIG_USB_SUSPEND=y"
    zgrep -q CONFIG_RTC_HCTOSYS=y /proc/config.gz || ewarn "Kernel is missing: CONFIG_RTC_HCTOSYS=y"

    grep 'must be set' /etc/localtime && eerror "Update the timezone"
    if [ ! -d /etc/timezone ]; then
        ewarn "You are missing /etc/timezone"
    fi

    # @todo check in /etc/make.conf for stuff
    # einfo "Configure /etc/make.conf with"
    # einfo "  GENTOO_MIRRORS=\"http://carbon.edoceo.com/praxis/gentoo\""
    # einfo "  PORTAGE_BINHOST=\"http://carbon.edoceo.com/praxis/<profile/\""
    # einfo

    chk=$(eval source "${ROOT}/etc/portage/make.conf"; echo $SYNC)
    if [[ $chk != "rsync://cdn.edoceo.com/praxis" ]]; then
        eerror "  Update: ${ROOT}/etc/make.conf"
        eerror "  SYNC=\"rsync://cdn.edoceo.com/praxis\""
        eerror
    fi

    chk=$(eval source "${ROOT}/etc/portage/make.conf"; echo $PORTAGE_BINHOST)
    case "$arch" in
    "x32")
        echo "Use Aluminium or Nitrogen"
        arch_profile="aluminium"
        ;;
    "x64")
        if [[ $chk != "http://cdn.edoceo.com/praxis/silicon" ]]; then
            if [[ $chk != "http://cdn.edoceo.com/praxis/neon" ]]; then
                errorr
                eerror "  Update: ${ROOT}/etc/portage/make.conf"
                eerror "  PORTAGE_BINHOST=\"http://cdn.edoceo.com/praxis/x64\""
                eerror
            fi
        fi
        ;;
    esac

    # chk=$(eval source "${ROOT}/etc/make.conf"; echo $GENTOO_MIRRORS)
    # if [[ $chk != "http://carbon.edoceo.com/praxis/gentoo" ]]; then
    #     eerror "  Update: ${ROOT}/etc/make.conf"
    #     eerror "  GENTOO_MIRRORS=\"http://carbon.edoceo.com/praxis/gentoo\""
    #     eerror
    # fi

    # grep BINHOST /etc/make.conf

    # Check stale libmpfr
    if [ -e /usr/lib64/libmpfr.so.1 ]; then
        ewarn "  Remove /usr/lib64/libmpfr.so.1 and then revdep-rebuild"
    fi
    if [ -e /usr/lib/libmpfr.so.1 ]; then
        ewarn "  Remove /usr/lib/libmpfr.so.1 and then revdep-rebuild"
    fi

    # Check for libpng
    if [ -e /usr/lib64/libpng14.so.14 ]; then
        ewarn "  Remove /usr/lib64/libpng14.so.14 and then revdep-rebuild"
    fi
    if [ -e /usr/lib/libpng14.so.14 ]; then
        ewarn "  Remove /usr/lib/libpng14.so.14 and then revdep-rebuild"
    fi
    
    # @todo check for proper setting of /etc/rc.conf:$rc_sys
    

    # @todo check in /etc/make.conf for stuff
    einfo "Configure /etc/slim.conf"
    einfo
    einfo "  current_theme       praxis"
    einfo

    einfo "Configure /boot/syslinux.conf"
    einfo
    einfo "menu vesa.c32"
    einfo "display /boot/praxis.png"
    einfo


}

#
# Copy ${D}
src_install()
{
    # ewarn
    # ewarn "src_install()"
    # echo "A=${A}"
    # echo "CATEGORY=${CATEGORY}"
    # echo "D=${D}"
    # echo "FILESDIR=${FILESDIR}"
    # echo "P=${P}"
    # echo "PF=${PF}"
    # echo "PN=${PN}"
    # echo "PR=${PR}"
    # echo "PV=${PV}"
    # echo "PVR=${PVR}"
    # echo "ROOT=${ROOT}"
    # echo "S=${S}"
    # echo "T=${T}"
    # echo "WORKDIR=${WORKDIR}"
    # echo "cwd=" $(pwd)
    # ewarn

    keepdir /opt/edoceo
    keepdir /opt/edoceo/sbin

    # Install the Basic Edoceo Scripts
    exeopts --backup=numbered --owner=atom --group=edoceo --mode=0755 --verbose

    # Set Target Directory
    exeinto /opt/edoceo/sbin
    # Copy from ${WORKDIR}
    doexe opt/edoceo/sbin/praxis.sh
    doexe opt/edoceo/sbin/praxis-binhost-update.sh

    #doexe opt/edoceo/sbin/praxis-binhost-emerge.sh
    #doexe opt/edoceo/sbin/praxis-emerge.sh
    #doexe opt/edoceo/sbin/praxis-portage-update.sh
    #doexe opt/edoceo/sbin/praxis-stage4-create.sh

    # @todo make symlinks in /usr/local/sbin to praxis-*
    #cp -R "${S}/" "${D}/" || die "Install Failed!"
    
    # For my Theme
    keepdir /usr/share/slim/themes/edoceo/


    return
}
