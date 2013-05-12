# Copyright 2006-2009 Edoceo, Inc.
# :mode=shellscript:

EAPI="4"

inherit eutils

# Required Variables
DESCRIPTION="Edoceo Custos System"
HOMEPAGE="http://custos.edoceo.com/"
IUSE=""
KEYWORDS="amd64 x86"
LICENSE="MIT"
SLOT="0"
# SRC_URI="http://cdn.edoceo.com/praxis/$PF.tgz"
RESTRICT="mirror"

DEPEND="
dev-lang/php[apache2,curl,ipv6,json,simplexml,ssl,unicode]
net-analyzer/nikto
>=net-analyzer/openvas-5
www-servers/apache
"

# Extract this tarball to the ${WORKDIR}
# Called during unpack|merge
src_unpack()
{
#    echo "A=${A}"
#    echo "CATEGORY=${CATEGORY}"
#    echo "D=${D}"
#    echo "FILESDIR=${FILESDIR}"
#    echo "P=${P}"
#    echo "PF=${PF}"
#    echo "PN=${PN}"
#    echo "PR=${PR}"
#    echo "PV=${PV}"
#    echo "PVR=${PVR}"
#    echo "ROOT=${ROOT}"
#    echo "S=${S}"
#    echo "T=${T}"
#    echo "WORKDIR=${WORKDIR}"

    unpack ${A}

    # cd "${S}"
    # ls -alh
    # sed -i '/^AWK/s:nawk:gawk:' Makefile #214865
    # dnsmasq on FreeBSD wants the config file in a silly location, this fixes
    # epatch "${FILESDIR}/${P}-fbsd-config.patch"
}

#
# What to do here?
# Right before merged to $ROOT
pkg_preinst()
{
    ewarn "pkg_preinst()"

    chk=$(eval zgrep CONFIG_SYSVIPC /proc/config.gz; echo $CONFIG_SYSVIPC)
    if [[ "$chk" != "y" ]]; then
        eerror "Kernel is missing: CONFIG_SYSVIPC=y"
    fi

    chk=$(eval zgrep CONFIG_USB_SUSPEND /proc/config.gz; echo $CONFIG_USB_SUSPEND)
    if [[ "$chk" != "y" ]]; then
        eerror "Kernel is missing: CONFIG_USB_SUSPEND=y"
    fi

    egrep '^en_US' /etc/locale.gen || die "Update Locale"
    grep -b 'must be set' /etc/localtime && die "Update the timezone"


    die "preinst failed"
}

# What to do here?
pkg_prerm()
{
    ewarn "pkg_prerm()"
    return
}

# What to do here?
# Right after Merged with $ROOT
pkg_postinst()
{
    ewarn "pkg_postinst()"
    env |sort

    # http://www.openvas.org/install-source.html
    ewarn
    ewarn "This seems like the right place to install OpenVAS"
    ewarn

    ewarn
    ewarn "Adding the Custos user for OpenVAS/Greenbone"
    ewarn
    openvasad -c add_user -n custos -r Addmin

    ewarn
    ewarn "Making Client Certificates"
    ewarn "Certs in: /var/lib/openvas"
    ewarn
    openvas-mkcert

    einfo
    einfo "Syncing the Feed"
    einfo

    openvas-nvt-sync
    openvasmd --rebuild --verbose

    greenbone-nvt-sync

    ewarn
    ewarn "Adding OpenVAS to the default runlevel"
    ewarn

    eselect rc add sshd default
    # eselect rc add openvasad default
    # eselect rc add openvasmd default
    eselect rc add openvassd default

    einfo
    einfo "Update cron to Sync the NVT"
    einfo
    einfo "5 5 * * * /opt/edoceo/custos/sbin/cron-daily.sh"
    einfo


#    cd /usr/src
#    wget http://wald.intevation.org/frs/download.php/979/openvas-libraries-4.0.6.tar.gz
#    tar -zxf openvas-libraries-4.0.6.tar.gz
#    cd openvas-libraries-4.0.6.tar.gz
#    cmake -DCMAKE_INSTALL_PREFIX=/opt/openvas
#    make
#    make install
#
#    wget http://wald.intevation.org/frs/download.php/983/openvas-scanner-3.2.5.tar.gz
#    tar -zxf openvas-scanner-3.2.5.tar.gz
#
#    wget http://wald.intevation.org/frs/download.php/871/openvas-manager-2.0.4.tar.gz
#    tar -zxf openvas-manager-2.0.4.tar.gz
#
#    wget http://wald.intevation.org/frs/download.php/987/openvas-administrator-1.1.2.tar.gz
#    tar -zxf openvas-administrator-1.1.2.tar.gz
#
#    wget http://wald.intevation.org/frs/download.php/857/greenbone-security-assistant-2.0.1.tar.gz
#    tar -zxf greenbone-security-assistant-2.0.1.tar.gz
#
#    wget http://wald.intevation.org/frs/download.php/971/openvas-cli-1.1.3.tar.gz
#    tar -zxf openvas-cli-1.1.3.tar.gz

    return
}

# What to do here?
pkg_postrm()
{
    ewarn "pkg_postrm()"
    return
}

#
# Copy stuff from ${S} to ${D}
#
src_install()
{
    ewarn "src_install()"

    keepdir /opt/edoceo/custos

    # echo "cp -R \"${S}/\" \"${D}/\" || die \"Install Failed!\""
    rsync -a "${S}/" "${D}/opt/edoceo/custos/" || die "Install Failed!"

    # env|sort
    # find "$D" |sort

    return
}
