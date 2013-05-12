# Evergreen ILS / Open ILS
# :mode=shellscript:

# @see  http://forums.funtoo.org/viewtopic.php?id=1229 - about using a GIT source

EAPI="4"

inherit eutils

# Required Variables
DESCRIPTION="Evergreen OpenILS"
HOMEPAGE="http://open-ils.org/"
IUSE=""
KEYWORDS="~amd64 ~x86"
LICENSE="GPL"
SLOT="2"
SRC_URI="" # http://cdn.edoceo.com/element/$PF.tgz"
# EGIT_REPO_URI="git://git.evergreen-ils.org/Evergreen.git"
RESTRICT="mirror"

DEPEND="
dev-lang/perl[ithreads]
dev-libs/libxml2[static-libs]
>=dev-libs/yaz-4.2.30
dev-perl/Class-DBI-AbstractSearch
dev-perl/Cache-Memcached
dev-perl/Class-Factory-Util
dev-perl/Class-Singleton
dev-perl/DateTime-Locale
dev-perl/DateTime-TimeZone
dev-perl/DateTime
dev-perl/DateTime-Format-Builder
dev-perl/DateTime-Format-Mail
dev-perl/DateTime-Format-ISO8601
dev-perl/DateTime-Format-Strptime
dev-perl/DateTime-Set
dev-perl/Email-Send
dev-perl/FreezeThaw
dev-perl/GD-Graph3d
dev-perl/JavaScript-SpiderMonkey
dev-perl/IO-Multiplex
dev-perl/List-MoreUtils
dev-perl/MARC-Record
dev-perl/MARC-XML
dev-perl/Params-Validate
dev-perl/Parse-RecDescent
dev-perl/JSON-XS
dev-perl/RPC-XML
dev-perl/Spreadsheet-WriteExcel
dev-perl/SRU
dev-perl/Text-Aspell
dev-perl/Text-CSV
dev-perl/Text-CSV_XS
dev-perl/Text-Glob
dev-perl/Tie-IxHash
dev-perl/UNIVERSAL-require
dev-perl/Unix-Syslog
dev-perl/XML-LibXML
dev-perl/XML-LibXSLT
dev-perl/XML-NamespaceSupport
dev-perl/XML-Parser
dev-perl/XML-SAX
dev-perl/XML-Simple
dev-perl/common-sense
dev-perl/locale-maketext-lexicon
dev-perl/net-server
dev-perl/string-crc32
dev-perl/libwww-perl
net-libs/libssh2
perl-core/Attribute-Handlers
perl-core/Time-Local
www-servers/apache
"

function pkg_postinst()
{
    ewarn
    ewarn "This is just a meta-package for now"
    ewarn

}
