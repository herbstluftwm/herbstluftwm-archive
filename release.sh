#!/usr/bin/env bash

set -e
version="$1"

if [ -z "$1" ] || [ "$1" = -h ] ; then
    echo "$0 VERSIONMAJOR.VERSIONMINOR.VERSIONPATCH"
    echo "  Releases the specified version (tagging and tarball creation)"
    exit 0
fi

if ! [ -d ipc-client ] ; then
    cat >&2 <<EOF
Error: This script must be run from the main herbstluftwm repository!

For example, invoke:

    ../herbstluftwm-archive/release.sh 0.9.9

from the herbstluftwm/ git directory.
EOF
    exit 1
fi

if git status --porcelain | grep '^ M' ; then
    echo "WARNING: You have unstaged changes. Fix them, or add them (for inclusion in the release commit)" >&2
    exit 1
fi

echo "==> Release commit"
echo ":: Patching VERSION"
echo "$version" > VERSION

echo ":: Patching NEWS"
date=$(date +%Y-%m-%d)
newheader="Release $version on $date"
newunderline="$(echo $newheader | sed 's/./-/g')"
headerexp="^Current git version$"
# this requires new sed
sed -i -e "/$headerexp/,+1s/^[-]*$/$newunderline/" \
       -e "s/$headerexp/$newheader/" NEWS

echo ":: Committing changes"
git add NEWS VERSION
git commit -a -m "Release $version"
echo ":: Tagging commit"
git tag -s "v$version" -m "Release $version"

echo "==> Tarball"
echo ":: Tarball creation"
builddir=.build-doc-"$version"
mkdir -p "$builddir"
pushd "$builddir"
cmake -DCOPY_DOCUMENTATION=NO ..
popd
make -C "$builddir" all_doc
builddir="$builddir" ci/mktar.sh
tarball="herbstluftwm-${version}.tar.gz"
gpg --detach-sign "${tarball}"

md5sum=$(md5sum "$tarball" | head -c 13 )
echo ":: Patching www/download.txt"
line=$(printf "| %-7s | $date | $md5sum...%15s| link:tarballs/%s[tar.gz] |link:tarballs/%s.sig[sig]" \
                $version                  ' '                 "$tarball" "$tarball")
linerexp="// do not remove this: next version line will be added here"
sed -i "s#^$linerexp\$#$line\n$linerexp#" www/download.txt
echo ":: Committing changes"
git add www/download.txt
git commit -m "www: Add $version tarball"

echo
echo "Still to do:"
echo "1. Add the following line to the MD5SUMS file on the mirror:"
md5sum "$tarball"
echo "2. Make www files and install them on the remote"
echo "3. Push the changes to all public remotes (including --tags)"
