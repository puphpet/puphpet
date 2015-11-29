#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')
MODULES_FOLDER="${VAGRANT_CORE_FOLDER}/puppet/modules"

function uz()
{
    ZIP=$(echo "$1")
    DEST=$(echo "$2")

    unzip -d "${DEST}" "${ZIP}" && f=("${DEST}"/*) && mv "${DEST}"/*/* "${DEST}" && rmdir "${f[@]}"
}

if [[ -d "${MODULES_FOLDER}/puphpet" ]]; then
    exit 0
fi

URL="https://puphpet.com/download-puppet-modules"
SAVE_TO="/.puphpet-stuff/puppet-modules.zip"

echo "Downloading missing Puppet modules"

wget --quiet --tries=5 --connect-timeout=10 -O ${SAVE_TO} ${URL}
uz ${SAVE_TO} ${MODULES_FOLDER}

echo "Done downloading missing Puppet modules"
