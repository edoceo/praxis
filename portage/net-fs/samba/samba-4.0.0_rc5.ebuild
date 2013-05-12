# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-4.0.0_alpha11.ebuild,v 1.6 2011/09/30 14:51:47 vostorga Exp $
# :mode=shellscript:

EAPI="4"

inherit confutils

MY_PV="${PV/_rc/rc}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Samba Server component"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/samba4/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="4"
KEYWORDS="amd64 x86"
IUSE="caps gnutls sqlite threads +client +server +tools +python"

DEPEND="!net-fs/samba-libs
	!net-fs/samba-server
	!net-fs/samba-client
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	caps? ( sys-libs/libcap )
	gnutls? ( net-libs/gnutls )
	sqlite? ( >=dev-db/sqlite-3 )
	>=sys-libs/talloc-2.0.5
	>=sys-libs/tdb-1.2.9
	>=sys-libs/tevent-0.9.16"
	#=sys-libs/ldb-0.9.10 No release yet
    # See source4/min_versions.m4 for the minimal versions

RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}"

pkg_setup()
{
    # not really used in this ebuild, just saving for reference
	SBINPROGS=""
	if use server ; then
		SBINPROGS="${SBINPROGS} bin/samba"
	fi
	if use client ; then
		SBINPROGS="${SBINPROGS} bin/mount.cifs bin/umount.cifs"
	fi

	BINPROGS=""
	if use client ; then
		BINPROGS="${BINPROGS} bin/smbclient bin/net bin/nmblookup bin/ntlm_auth"
	fi
	if use server ; then
		BINPROGS="${BINPROGS} bin/testparm bin/smbtorture"
	fi
	if use tools ; then
		# Should be in sys-libs/ldb, but there's no ldb release yet
		BINPROGS="${BINPROGS} bin/ldbedit bin/ldbsearch bin/ldbadd bin/ldbdel bin/ldbmodify bin/ldbrename"
	fi

	confutils_use_depend_all server python
}

src_configure()
{
	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	econf \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--enable-developer \
		--enable-fhs \
		$(use_enable gnutls) \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--with-modulesdir=/usr/lib/samba/modules \
		--with-privatedir=/var/lib/samba/private \
		--with-lockdir=/var/lock/samba \
		--with-logfilebase=/var/log/samba \
		--with-piddir=/var/run/samba
}

src_compile()
{
	emake all
}

src_install()
{
	# this works but I'd rather einstall
	./buildtools/bin/waf install --destdir=${D}

	# These would collide - what to do?
	# @test remove sys-libs/tdb first?
	# @note this worked to avoid collisions but I'm sad we lost tdbtool and tdbrestore ?
	# rm -v ${D}/usr/bin/tdbrestore
	# rm -v ${D}/usr/bin/tdbtool

}

src_test()
{
	emake test DESTDIR="${D}" || die "Test failed"
}

pkg_postinst()
{
	# Optimize the python modules so they get properly removed
	# @todo find out if we still do this stuff?
	# use python && python_mod_optimize $(python_get_sitedir)/${PN}

	# Warn that it's an alpha
	ewarn "Samba 4 is beta therefore not considered stable. It's only"
	ewarn "meant to test and experiment and not intended for production."
}

pkg_postrm()
{
	# Clean up the python modules
	use python && python_mod_cleanup $(python_get_sitedir)/${PN}
}
