#!/bin/bash
# :mode=shellscript:
#
# This script updates our portage, builds packages, pushes to host
#

set -o errexit
set -o nounset

export EMERGE_DEFAULT_OPTS="--alphabetical --nospinner --misspell-suggestions=n"
export NOCOLOR="true"
export PORTAGE_NICENESS=15

# Check for the binhost to push to
binhost=$(eval source /etc/make.conf; echo $praxis_binhost)
if [[ -z "$binhost" ]]; then
    echo "praxis_binhost is not set"
    echo "Update /etc/make.conf"
    echo "  praxis_binhost=\"http://cdn.edoceo.com/praxis/x64\""
    exit;
fi

log=$(mktemp)

# pre-clean
rm -f /var/log/emerge.log
rm -f /var/log/emerge-fetch.log
rm -f /var/log/portage/elog/summary.log

# Sync
echo "* --sync"
emerge --sync >$log

# Update
echo "* --update"
emerge --deep --newuse --update @world >>$log

# Check if PERL was updated  & do perl-cleaner
echo "* perl-cleaner"
perl-cleaner --all >>$log
emerge --oneshot perl-core/ExtUtils-ParseXS >>$log

# Check if Python was update & do python-updater
echo "* python-updater"
python-updater >>$log

# Check if Ruby was updated

#
# Security Check
echo "* glsa-check"
# /opt/edoceo/sbin/element.sh glsa
glsa-check --test all

# Check for some revdep-rebuild stuff
echo "* revdep-rebuild"
revdep-rebuild --ignore --pretend --nocolor --no-progress --quiet

#
# Cleanup
echo "* --depclean"
emerge --depclean --pretend
# (emerge --depclean --pretend | grep "All selected packages" | cut -d: -f2) || true


#
# Prune
echo "* Packages to Prune [ --prune ]"
emerge --prune --pretend
# (emerge --prune --pretend | egrep '^ \w+|^ +selected') || true

#
# eclean stuff
eclean distfiles
eclean packages

#
# Show Logs
#if [ -f /var/log/portage/elog/summary.log ]; then
#  cat /var/log/portage/elog/summary.log
#fi

# Log Package Size
equery size '*' \
    | awk '{ print $4 " " $1 }' \
    | sed 's/size//' | sed 's/[()]//g' \
    | sort --numeric-sort --reverse \
    > /usr/portage/packages/package.size

# Log Package Details
emerge --emptytree --pretend --verbose world \
    | grep '^\[ebuild' \
    | cut -c17- \
    | sort \
    > /usr/portage/packages/package.info

# Push my Packages Up
# It's up to the binhost to prune itself
rsync --archive --verbose /usr/portage/packages/ $binhost/
