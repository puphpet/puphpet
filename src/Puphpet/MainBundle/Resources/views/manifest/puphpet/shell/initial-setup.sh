#!/bin/bash

VAGRANT_CORE_FOLDER=$(echo "$1")

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [[ ! -d /.puphpet-stuff ]]; then
    mkdir /.puphpet-stuff

    echo "${VAGRANT_CORE_FOLDER}" > "/.puphpet-stuff/vagrant-core-folder.txt"

    cat "${VAGRANT_CORE_FOLDER}/shell/self-promotion.txt"
    echo "Created directory /.puphpet-stuff"
fi

if [[ ! -f /.puphpet-stuff/initial-setup-repo-update ]]; then
    if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
        echo "Running initial-setup apt-get update"
        apt-get update >/dev/null
        touch /.puphpet-stuff/initial-setup-repo-update
        echo "Finished running initial-setup apt-get update"
    elif [[ "${OS}" == 'centos' ]]; then
        echo "Running initial-setup yum update"
        yum install yum-plugin-fastestmirror -y >/dev/null
        yum check-update -y >/dev/null
        echo "Finished running initial-setup yum update"

        echo "Updating to Ruby 1.9.3"
        yum install centos-release-SCL >/dev/null
        yum remove ruby >/dev/null

        # As described here http://tecadmin.net/install-ruby-1-9-3-or-multiple-ruby-verson-on-centos-6-3-using-rvm/
        yum install gcc-c++ patch readline readline-devel zlib zlib-devel >/dev/null
        yum install libyaml-devel libffi-devel openssl-devel make >/dev/null
        yum install bzip2 autoconf automake libtool bison iconv-devel >/dev/null
        curl -L get.rvm.io | bash -s stable
        source /etc/profile.d/rvm.sh
        rvm install 1.9.3
        rvm use 1.9.3 --default

        gem update --system >/dev/null
        gem install haml >/dev/null
        echo "Finished updating to Ruby 1.9.3"

        echo "Installing basic development tools (CentOS)"
        yum -y groupinstall "Development Tools" >/dev/null
        echo "Finished installing basic development tools (CentOS)"
        touch /.puphpet-stuff/initial-setup-repo-update
    fi
fi

if [[ "${OS}" == 'ubuntu' && ("${CODENAME}" == 'lucid' || "${CODENAME}" == 'precise') && ! -f /.puphpet-stuff/ubuntu-required-libraries ]]; then
    echo 'Installing basic curl packages (Ubuntu only)'
    apt-get install -y libcurl3 libcurl4-gnutls-dev curl >/dev/null
    echo 'Finished installing basic curl packages (Ubuntu only)'

    touch /.puphpet-stuff/ubuntu-required-libraries
fi
