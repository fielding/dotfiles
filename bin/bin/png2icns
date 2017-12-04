#!/bin/sh
#   This runs silent, be as verbose as you wish
NAME=$(basename ${1} .png)
DIR="${NAME}.iconset"
mkdir -p ${DIR}
for i in 16 32 128 256 512 ; do
    x=""
    for p in $i $(($i+$i)) ; do
        sips -z $p $p ${1} --out "${NAME}.iconset/icon_${i}x${i}${x}.png"
        x="@2x"
    done
done >/dev/null  # /dev/null in lieu of a "-s" silent option
iconutil -c icns $DIR
rm -r $DIR
