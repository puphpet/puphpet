#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [[ ! -f /.puphpet-stuff/install-puppet ]]; then
    echo 'Installing Puppet'

    if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
        URL="https://apt.puppetlabs.com/puppetlabs-release-pc1-${CODENAME}.deb"
        wget --quiet --tries=5 --connect-timeout=10 -O /.puphpet-stuff/puppetlabs-release-pc1.deb ${URL}
        dpkg -i /.puphpet-stuff/puppetlabs-release-pc1.deb
        apt-get update
        apt-get -y install puppet-agent=1.3.6*
    elif [[ "${OS}" == 'centos' ]]; then
        if [ "${RELEASE}" == 6 ]; then
            rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
            yum -y install puppet-agent-1.3.6
        fi
    fi

    rm -f /usr/bin/puppet
    ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet

    echo 'Finished installing Puppet'
    touch /.puphpet-stuff/install-puppet
fi

/opt/puppetlabs/puppet/bin/gem install deep_merge activesupport vine --no-ri --no-rdoc
