#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

if [[ ! -d /.puphpet-stuff ]]; then
    mkdir /.puphpet-stuff
    echo "Created directory /.puphpet-stuff"
fi

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
    if [[ ! -f /.puphpet-stuff/initial-setup-apt-get-update ]]; then
        echo "Running initial-setup apt-get update"
        apt-get update >/dev/null
        touch /.puphpet-stuff/initial-setup-apt-get-update
        echo "Finished running initial-setup apt-get update"
    fi
fi
