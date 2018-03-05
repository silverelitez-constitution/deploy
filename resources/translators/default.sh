#!/bin/bash
# This deployment script has been lovingly crafted for
# Gentoo, Centos

echo "You're using ${PRETTY_NAME}"
echo "OS ID: ${ID}"
echo "Visit us at ${HOME_URL}"
echo "Got a problem? Let us know at ${BUG_REPORT_URL}!"

# Bits that just happen to be common, put them here
P_INSTALL+=" --quiet "
P_REMOVE+=" --quiet "
