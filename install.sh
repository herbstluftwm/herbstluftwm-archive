#!/usr/bin/env bash

rsync -rva --exclude '*~' --exclude '.*.swp' --ignore-existing \
    tarballs/ \
    herbstluftwm.org:html/tarballs/

rsync -rva --exclude '*~' \
    tarballs/MD5SUMS \
    herbstluftwm.org:html/tarballs/MD5SUMS

rsync -rva --exclude '*~' --exclude '.*.swp' --ignore-existing \
    www/ \
    herbstluftwm.org:html/

