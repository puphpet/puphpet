#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    RVM_RUBIES='gems'
elif [[ "${OS}" == 'centos' ]]; then
    RVM_RUBIES='rubies'
fi

function check_puppet_symlink() {
    if [[ -f "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p547/bin/puppet" ]]; then
        rm -f '/usr/bin/puppet'
        ln -s "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p547/bin/puppet" '/usr/bin/puppet'
        return 0;
    elif [[ -f "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p551/bin/puppet" ]]; then
        rm -f '/usr/bin/puppet'
        ln -s "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p551/bin/puppet" '/usr/bin/puppet'
        return 0;
    fi

    # Puppet not installed
    if [ ! -L '/usr/bin/puppet' ]; then
        rm -f '/.puphpet-stuff/install-puppet'

        return 0;
    fi

    PUPPET_SYMLINK=$(ls -l /usr/bin/puppet);

    # If puppet symlink is old-style pointing to /usr/local/rvm/wrappers/default/ruby
    if [ "grep '/usr/local/rvm/wrappers/default' ${PUPPET_SYMLINK}" ]; then
        rm -f '/usr/bin/puppet'

        if [[ -f "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p547/bin/puppet" ]]; then
            ln -s "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p547/bin/puppet" '/usr/bin/puppet'
        elif [[ -f "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p551/bin/puppet" ]]; then
            ln -s "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p551/bin/puppet" '/usr/bin/puppet'
        else
            rm -f '/.puphpet-stuff/install-puppet'
        fi
    fi
}

check_puppet_symlink

if [[ -f '/.puphpet-stuff/install-puppet' ]]; then
    exit 0
fi

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    apt-get -y install augeas-tools libaugeas-dev
elif [[ "${OS}" == 'centos' ]]; then
    yum -y install augeas-devel
fi

echo 'Installing Puppet requirements'
/usr/bin/gem install haml hiera facter json ruby-augeas --no-document
echo 'Finished installing Puppet requirements'

echo 'Installing Puppet 3.4.3'
/usr/bin/gem install puppet --version 3.4.3 --no-document

if [[ -f '/usr/bin/puppet' ]]; then
    mv /usr/bin/puppet /usr/bin/puppet-old
fi

ln -s "/usr/local/rvm/${RVM_RUBIES}/ruby-1.9.3-p*/bin/puppet" /usr/bin/puppet
echo 'Finished installing Puppet 3.4.3'

touch '/.puphpet-stuff/install-puppet'
