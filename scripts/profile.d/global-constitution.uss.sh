#!/bin/bash
# This deployment script has been lovingly crafted for $(ls ../../resources/translators/)
source /etc/os-release

PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH

translation_layer
refresh_global
if [[ "${ID}" == "amzl" && ! -e /etc/yum.repos.d/epel* ]]; then sudo amazon-linux-extras install epel -y; fi
prep_prompt
