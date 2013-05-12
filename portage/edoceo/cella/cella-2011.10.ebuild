# Copyright 2006-2011 Edoceo, Inc.
# :mode=shellscript:

EAPI="4"

inherit eutils

# Required Variables
DESCRIPTION="Edoceo Cella Backup Tools"
HOMEPAGE="http://edoceo.com/creo/cella"
IUSE=""
KEYWORDS="amd64 x86"
LICENSE="MIT"
SLOT="0"
SRC_URI="http://cdn.edoceo.com/bin/${PN}.tgz"
RESTRICT="mirror"
RDEPEND="dev-lang/php[cli]"

#
# Functions
#
pkg_setup()
{
    enewgroup edoceo
    enewuser atom 65 /bin/bash /opt/edoceo edoceo
}

# Extract this tarball to the ${WORKDIR}
src_unpack()
{
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

    unpack ${A}

}

# What to do here?
pkg_config()
{
    ebegin "pkg_config($arch)"
    ewarn "System configuration stored in /etc/edoceo/cella.ini"
}

# What to do here?
pkg_postinst()
{
    # @todo check in /etc/make.conf for stuff
    
    ewarn "Should add Cella to the crontab"
    ewarn "  Like: fcrontab"
    ewarn "4 4 * * * /opt/edoceo/sbin/cella.php pack"
    ewarn
}

# Don't know what to do here
src_install()
{
    #ewarn "src_install()"
    #ewarn Working in $(pwd)
    #ewarn `find`

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

    keepdir /opt/edoceo
    keepdir /opt/edoceo/etc
    keepdir /opt/edoceo/sbin

    # Install the Basic Edoceo Scripts
    exeopts --backup=numbered --owner=atom --group=edoceo --mode=0755 --verbose
    exeinto /opt/edoceo/sbin
    doexe cella.php

    insopts --backup=numbered --owner=atom --group=edoceo --mode=0644 --verbose
    insinto /opt/edoceo/etc
    doins cella.ini

    # @todo make symlinks in /usr/local/sbin to element-*

    return
}
