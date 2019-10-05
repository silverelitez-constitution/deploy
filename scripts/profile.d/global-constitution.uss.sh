#!/bin/bash
# This deployment script has been lovingly crafted for $(ls ../../resources/translators/)
source /etc/os-release

PATH=$PATH:$HOME/.local/bin:$HOME/bin
export PATH

translation_layer
refresh_global
[[ ${ID} == "amzl" ]] && [[ -e /etc/yum.repos.d/epel* ]] || sudo amazon-linux-extras install epel -y
prep_prompt
