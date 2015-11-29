#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [[ -f /.puphpet-stuff/install-ruby-1.9.3-p551 ]]; then
    exit 0
fi

rm -rf /usr/bin/ruby /usr/bin/gem /usr/bin/rvm /usr/local/rvm

echo 'Installing RVM and Ruby 1.9.3'

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D39DC0E3
elif [[ "${OS}" == 'centos' ]]; then
    gpg2 --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D39DC0E3
fi

curl -sSL https://get.rvm.io | bash -s stable --quiet-curl --ruby=ruby-1.9.3-p551

source /usr/local/rvm/scripts/rvm

if [[ -f '/root/.bashrc' ]] && ! grep -q 'source /usr/local/rvm/scripts/rvm' /root/.bashrc; then
    echo 'source /usr/local/rvm/scripts/rvm' >> /root/.bashrc
fi

if [[ -f '/etc/profile' ]] && ! grep -q 'source /usr/local/rvm/scripts/rvm' /etc/profile; then
    echo 'source /usr/local/rvm/scripts/rvm' >> /etc/profile
fi

/usr/local/rvm/bin/rvm cleanup all
gem update --system
echo 'y' | rvm rvmrc warning ignore all.rvmrcs

echo 'Finished installing RVM and Ruby 1.9.3'

touch /.puphpet-stuff/install-ruby-1.9.3-p551
