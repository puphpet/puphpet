#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
    if [[ ! -f /.puphpet-stuff/update-puppet ]]; then
        echo "Downloading https://github.com/puphpet/apt-puppetlabs-com/raw/master/puppetlabs-release-${CODENAME}.deb"
        wget --quiet --tries=5 --timeout=10 -O "/.puphpet-stuff/puppetlabs-release-${CODENAME}.deb" "https://github.com/puphpet/apt-puppetlabs-com/raw/master/puppetlabs-release-${CODENAME}.deb"
        echo "Finished downloading https://github.com/puphpet/apt-puppetlabs-com/raw/master/puppetlabs-release-${CODENAME}.deb"

        dpkg -i "/.puphpet-stuff/puppetlabs-release-${CODENAME}.deb" >/dev/null

        echo "Running update-puppet apt-get update"
        apt-get update >/dev/null
        echo "Finished running update-puppet apt-get update"

        echo "Updating Puppet to latest version"
        apt-get -y install puppet >/dev/null
        PUPPET_VERSION=$(puppet help | grep 'Puppet v')
        echo "Finished updating puppet to latest version: $PUPPET_VERSION"

        touch /.puphpet-stuff/update-puppet
        echo "Created empty file /.puphpet-stuff/update-puppet"
    fi
fi
