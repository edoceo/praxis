# Evergreen ILS / OpenILS
# :mode=shellscript:

EAPI="3"

inherit eutils

DESCRIPTION="Evergreen OpenILS"
HOMEPAGE="http://open-ils.org/"
IUSE=""
KEYWORDS="~x86 amd64"
LICENSE="GPL-2"
SLOT="2.1"
SRC_URI="http://open-ils.org/downloads/Evergreen-ILS-2.1.0a.tar.gz"
RESTRICT="mirror"

DEPEND="dev-lang/perl[ithreads]
        dev-libs/libxml2[static-libs]
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
        dev-perl/JavaScript-SpiderMonkey
        dev-perl/IO-Multiplex
        dev-perl/List-MoreUtils
        dev-perl/MARC-Record
        dev-perl/MARC-XML
        dev-perl/Params-Validate
        dev-perl/Parse-RecDescent
        dev-perl/JSON-XS
        dev-perl/RPC-XML
        dev-perl/SRU
        dev-perl/Text-Aspell
        dev-perl/Text-CSV
        dev-perl/Text-Glob
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
        www-servers/apache"

# dev-db/postgresql-server-9.1.1 [9.0.5] USE="-doc nls pam perl -pg_legacytimestamp python (-selinux) -tcl uuid xml"

# g-cpan --install APR::Const APR::Table \
#     Business::CreditCard \
#     Business::ISBN \
#     Business::OnlinePayment \
#     Library::CallNumber::LC \
#     Net::SSH2 \
#     Template::Plugin \
#     UUID::Tiny

# Change User to Build?