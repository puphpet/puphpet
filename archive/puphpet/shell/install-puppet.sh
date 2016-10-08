#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [[ ! -f '/.puphpet-stuff/install-puppet' ]]; then
    if [[ "${OS}" == 'debian' || "${OS}" == 'ubuntu' ]]; then
        URL="https://apt.puppetlabs.com/puppetlabs-release-pc1-${CODENAME}.deb"
        wget --quiet --tries=5 --connect-timeout=10 -O /.puphpet-stuff/puppetlabs-release-pc1.deb ${URL}
        dpkg -i /.puphpet-stuff/puppetlabs-release-pc1.deb
        apt-get update
        apt-get -y install puppet-agent=1.6*
    fi

    if [[ "${OS}" == 'centos' ]]; then
        if [ "${RELEASE}" == 6 ]; then
            rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
            yum -y install puppet-agent-1.6*
        fi

        if [ "${RELEASE}" == 7 ]; then
            rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
            yum -y install puppet-agent-1.6*
        fi
    fi

    rm -f /usr/bin/puppet
    ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet
    touch /.puphpet-stuff/install-puppet
fi

GEM=/opt/puppetlabs/puppet/bin/gem

if ! (${GEM} list deep_merge | grep -q 'deep_merge'); then
    ${GEM} install deep_merge -v 1.0.1 --no-ri --no-rdoc
fi

if ! (${GEM} list activesupport | grep -q 'activesupport'); then
    ${GEM} install activesupport -v 4.2.6 --no-ri --no-rdoc
fi

if ! (${GEM} list vine | grep -q 'vine'); then
    ${GEM} install vine -v 0.2 --no-ri --no-rdoc
fi
