#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
    if [[ ! -f /puppet-updated ]]; then
        echo "Downloading http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
        wget --quiet -O /tmp/puppet.deb "http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
        dpkg -i /tmp/puppet.deb
        apt-get update && apt-get -y install puppet
        touch /puppet-updated
    fi
fi
