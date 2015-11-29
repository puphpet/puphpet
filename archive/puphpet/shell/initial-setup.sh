#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(echo "$1")

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)

cat "${VAGRANT_CORE_FOLDER}/shell/ascii-art/self-promotion.txt"
printf "\n"
echo ""

if [[ ! -d '/.puphpet-stuff' ]]; then
    mkdir '/.puphpet-stuff'
    echo 'Created directory /.puphpet-stuff'
fi

touch '/.puphpet-stuff/vagrant-core-folder.txt'
echo "${VAGRANT_CORE_FOLDER}" > '/.puphpet-stuff/vagrant-core-folder.txt'

# Use Anacron to run `apt-get update` once a week to keep repos fresh
if [[ ! -f '/.puphpet-stuff/anacron-installed' ]]; then
    if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
        echo 'Installing Anacron'
        apt-get update
        apt-get -y install anacron

        cat >/etc/cron.weekly/autoupdt << 'EOL'
#!/bin/bash

apt-get update
apt-get autoclean
EOL

        echo 'Finished installing Anacron'
    fi

    touch '/.puphpet-stuff/anacron-installed'
fi

# CentOS comes with tty enabled. RHEL has realized this is stupid, so we can
# also safely disable it in PuPHPet boxes.
if [[ ! -f '/.puphpet-stuff/disable-tty' ]]; then
    perl -pi'~' -e 's@Defaults(\s+)requiretty@Defaults !requiretty@g' /etc/sudoers

    touch '/.puphpet-stuff/disable-tty'
fi

# Digital Ocean seems to be missing iptables-persistent!
# See https://github.com/puphpet/puphpet/issues/1575
if [[ ! -f '/.puphpet-stuff/iptables-persistent-installed' ]] && [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    apt-get -y install iptables-persistent

    touch '/.puphpet-stuff/iptables-persistent-installed'
fi

if [[ ! -f '/.puphpet-stuff/resolv-conf-changed' ]]; then
    echo "nameserver 8.8.8.8" > /etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf

    touch '/.puphpet-stuff/resolv-conf-changed'
fi

if [[ -f '/.puphpet-stuff/initial-setup-base-packages' ]]; then
    exit 0
fi

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    echo 'Installing curl'
    apt-get -y install curl
    echo 'Finished installing curl'

    echo 'Installing git'
    apt-get -y install git-core
    echo 'Finished installing git'

    if [[ "${CODENAME}" == 'lucid' || "${CODENAME}" == 'precise' ]]; then
        echo 'Installing basic curl packages'
        apt-get -y install libcurl3 libcurl4-gnutls-dev
        echo 'Finished installing basic curl packages'
    fi

    echo 'Installing build-essential packages'
    apt-get -y install build-essential
    echo 'Finished installing build-essential packages'
elif [[ "${OS}" == 'centos' ]]; then
    echo 'Adding repos: elrepo, epel, scl'
    perl -p -i -e 's@enabled=1@enabled=0@gi' /etc/yum/pluginconf.d/fastestmirror.conf

    if [ "${RELEASE}" == 6 ]; then
        EL_REPO='http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm'
        EPEL='https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
    else
        EL_REPO='http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm'
        EPEL='https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm'
    fi

    yum -y --nogpgcheck install "${EL_REPO}"
    yum -y --nogpgcheck install "${EPEL}"
    yum -y install centos-release-SCL
    yum clean all
    yum -y check-update
    echo 'Finished adding repos: elrep, epel, scl'

    echo 'Installing curl'
    yum -y install curl
    echo 'Finished installing curl'

    echo 'Installing git'
    yum -y install git
    echo 'Finished installing git'

    echo 'Installing Development Tools'
    yum -y groupinstall 'Development Tools'
    echo 'Finished installing Development Tools'
fi

touch '/.puphpet-stuff/initial-setup-base-packages'
