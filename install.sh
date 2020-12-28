#!/usr/bin/env bash

rsync -rva --exclude '*~' --exclude '.*.swp' --ignore-existing \
    tarballs/ \
    herbstluftwm.org:html/tarballs/

rsync -rva --exclude '*~' --exclude '.*.swp' --ignore-existing \
    www/ \
    herbstluftwm.org:html/

