# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/openvas/openvas-4.ebuild,v 1.1 2011/10/09 17:40:24 hanno Exp $
# :mode=shellscript:

EAPI=4

DESCRIPTION="A remote security scanner"
HOMEPAGE="http://www.openvas.org/"
SLOT="6"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE="X"

DEPEND="
    >=net-analyzer/openvas-libraries-6.0.1
	>=net-analyzer/openvas-scanner-3.4.0
	>=net-analyzer/openvas-manager-4.0.4
	>=net-analyzer/openvas-administrator-1.3.2
	>=net-analyzer/openvas-cli-1.2.0
"

# >=net-analyzer/greenbone-security-assistant-3.0.0
# X? ( >=net-analyzer/greenbone-security-desktop-1.2.1 )"

RDEPEND="${DEPEND}"
