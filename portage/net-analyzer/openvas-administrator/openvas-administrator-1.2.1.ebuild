# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/openvas-administrator/openvas-administrator-1.1.1.ebuild,v 1.1 2011/10/09 17:21:05 hanno Exp $
# :mode=shellscript:

EAPI=4

inherit cmake-utils

DESCRIPTION="A remote security scanner for Linux (openvas-administrator)"
HOMEPAGE="http://www.openvas.org/"
SRC_URI="http://wald.intevation.org/frs/download.php/1140/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64"
IUSE=""

RDEPEND=">=net-analyzer/openvas-libraries-5"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/cmake"

# Workaround for upstream bug, it doesn't like out-of-tree builds.
CMAKE_BUILD_DIR="${S}"

src_configure() {
	local mycmakeargs="-DLOCALSTATEDIR=/var -DSYSCONFDIR=/etc"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc ChangeLog CHANGES README || die "dodoc failed"
	doinitd "${FILESDIR}"/openvasad
}

pkg_postinst() {
	elog "You need to create an admin user for openvasad to work:"
	elog "openvasad -c 'add_user' -n [username] -r Admin"
}
