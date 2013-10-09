#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
    if [[ ! -f /puppet-updated ]]; then
        echo "Downloading https://github.com/puphpet/apt-puppetlabs-com/raw/master/puppetlabs-release-${CODENAME}.deb"
        wget --quiet --tries=5 --timeout=10 -O /tmp/puppet.deb "https://github.com/puphpet/apt-puppetlabs-com/raw/master/puppetlabs-release-${CODENAME}.deb"
        dpkg -i /tmp/puppet.deb
        apt-get update
        apt-get -y install puppet
        touch /puppet-updated
    fi
fi
