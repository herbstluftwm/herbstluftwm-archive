#!/bin/bash

set -e
===() {
    echo -e "\e[1;32m===\e[1;37m $* \e[1;32m===\e[0m"
}

pushd tarballs/
    === "Checking tarball/MD5SUMS"
    diff -us <(md5sum herbstluftwm-*.tar.gz) MD5SUMS
popd

for i in tarballs/*.sig ; do
    === "Checking signature $i"
    gpg --output "${i%.sig}" --decrypt "${i}"
done

pushd tarballs/
    === "Checking availability of tarballs"
    for i in herbstluftwm-*.tar.gz ; do
        url=http://herbstluftwm.org/tarballs/$i
        === "... $url"
        diff -us <(wget -q -O - "$url") "$i"
    done
popd
