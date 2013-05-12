#!/bin/bash

#
# makes an Element Package
# pushes to Lithium
#

cmd=$(readlink -f "$0")
mwd=$(dirname "$cmd")
tmp=$(mktemp -d)

# rev=$(svn info $mwd@HEAD | awk ' /^Revision/ { print $2 }')
rev=$(date +%Y.%W)

tgz=element-$rev.tgz

svn export --force https://carbon.edoceo.com/svn/element/sysroot $tmp

tar -vzcf $tgz -C $tmp/ ./

rm -fr $tmp

# scp $tgz root@argon.edoceo.com:/var/www/cdn.edoceo.com/element/
rm $tgz

# make ebuild in our tree for me?
# sed 's/^SRC_URI.*/SRC_URI=http://cdn.edoceo.com/
# cp "$mwd/element.ebuild" "$mwd/../portage/edoceo/element/element-$rev.ebuild"

pushd $(dirname $mwd)/sysroot/

tar -zcf ../praxis-2012.31.tgz \
    ./opt/edoceo/sbin/praxis.sh \
    ./opt/edoceo/sbin/praxis-portage-mirror.sh \
    ./opt/edoceo/sbin/praxis-binhost-update.sh

popd
scp ./praxis-2012.31.tgz root@neon.edoceo.com:/var/www/cdn.edoceo.com/praxis/
rm ./praxis-2012.31.tgz