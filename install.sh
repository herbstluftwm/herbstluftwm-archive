#!/usr/bin/env bash

rsync -rva --exclude '*~' --exclude '.*.swp' --ignore-existing tarballs/ herbstluftwm.org:www/tarballs/
rsync -rva tarballs/MD5SUMS herbstluftwm.org:www/tarballs/MD5SUMS

