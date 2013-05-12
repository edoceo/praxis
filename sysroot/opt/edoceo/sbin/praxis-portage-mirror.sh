#!/bin/bash
# @file
# @brief Updates this Praxis Mirror

set -o errexit

# @todo detect default profile?
gentoo_profile="default/linux/amd64/13.0"
praxis_profile="edoceo/praxis/x64"

# Stop Others from pulling from us while we update
# /etc/init.d/rsyncd --nocolor stop >/dev/null

# Ensure that our sync will get latest, block downstream
rm -f /usr/portage/metadata/timestamp
rm -f /usr/portage/metadata/timestamp.chk
rm -f /usr/portage/metadata/timestamp.x

# Synx to Gentoo
export SYNC="rsync://rsync.gentoo.org/gentoo-portage"
eselect profile set $gentoo_profile
emerge --sync >/dev/null || true

#  (can be in /etc/portage/postsync.d/ )
#  Runs after the emerge --sync to automatically merge in the Element
#  set > /tmp/postsync.env

#
# add my stuffs to portage
log_svn=$(mktemp)
svn export --force https://edoceo.com/svn/praxis/portage/ /usr/portage/ >$log_svn || true

#
# purge Praxis distfiles so we start fresh
rm -fr /usr/portage/distfiles/praxis* >/dev/null

#
# add edoceo to the categories
grep -q edoceo /usr/portage/profiles/categories || echo 'edoceo' >> /usr/portage/profiles/categories

#
# Add profiles to the profile list
grep -q 'edoceo' /usr/portage/profiles/profiles.desc || (

cat >> /usr/portage/profiles/profiles.desc <<EOS

# These lines added by Edoceo

# @deprecated, leave till all 32bits are gone
x86 edoceo/praxis/x32     stable
x86 edoceo/praxis/x32/gui stable

amd64 edoceo/nucleus    stable
amd64 edoceo/praxis     stable
amd64 edoceo/praxis/gui stable
EOS

)

# Rebuild Digests
for f in $(awk '/\.ebuild$/ { print $2 }' $log_svn); do
    ebuild $f digest >/dev/null || true
done
rm -fr $log_svn

# Update Portage Timestamp
# date --utc +'%a %b %e %H:%M:%S %Z %Y' > /usr/portage/metadata/timestamp
# date --utc +'%a, %d %b %Y %H:%M:%S %z' > /usr/portage/metadata/timestamp.chk
# date --utc +'%s %a %b %e %H:%M:%S %Y %Z'   > /usr/portage/metadata/timestamp.x

# Restore Profile
eselect profile set $praxis_profile

# Trim our Portage Binhost Root
# find /var/www/cdn.edoceo.com/element/ -type f -mtime +1095 -exec rm -fv {} +
# /etc/init.d/rsyncd --nocolor start >/dev/null

