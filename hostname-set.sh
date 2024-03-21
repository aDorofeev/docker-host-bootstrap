#!/usr/bin/env bash

set -euo pipefail

NEWNAME=$1
OLDNAME=${2:-}
if [ -z ${OLDNAME} ] ; then
    OLDNAME=$(hostname)
fi

OLDNAME_SHORT=$(echo "$OLDNAME" | grep -oP '^[^\.]+')
NEWNAME_SHORT=$(echo "$NEWNAME" | grep -oP '^[^\.]+')

sed "s/$OLDNAME/$NEWNAME/g" -i /etc/hosts
sed "s/$OLDNAME_SHORT/$NEWNAME_SHORT/g" -i /etc/hosts

find /etc/ssh/ -name "*.pub" -type f | xargs -i sed "s/$OLDNAME_SHORT/$NEWNAME_SHORT/g" -i {}

echo $NEWNAME > /etc/hostname
echo $NEWNAME > /etc/mailname

hostname "$NEWNAME"

