#!/bin/sh
echo "Europe/Paris" > /etc/timezone
dpkg-reconfigure tzdata
date
set -e
exec /run.sh