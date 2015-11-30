#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [[ -f /.puphpet-stuff/install-puppet ]]; then
    exit 0
fi

echo 'Installing Puppet'

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    echo "Debian support coming soon"
elif [[ "${OS}" == 'centos' ]]; then
    if [ "${RELEASE}" == 6 ]; then
        rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
        yum -y install puppet-agent

        rm -f /usr/bin/puppet
        ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet

        /opt/puppetlabs/puppet/bin/gem install deep_merge activesupport vine --no-ri --no-rdoc
    fi
fi

echo 'Finished installing Puppet'
touch /.puphpet-stuff/install-puppet
