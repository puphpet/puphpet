#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet
PUPHPET_STATE_DIR=/opt/puphpet-state

# Run from Vagrant CLI
if [[ -d /vagrant ]]; then
    if [[ ! -L ${PUPHPET_CORE_DIR} ]]; then
        ln -s /vagrant/puphpet ${PUPHPET_CORE_DIR}
    fi
# Run as stand-alone Puppet
else
    if [[ ! -d ${PUPHPET_CORE_DIR} ]]; then
        mkdir ${PUPHPET_CORE_DIR}
    fi
fi

if [[ ! -d ${PUPHPET_STATE_DIR} ]]; then
    mkdir ${PUPHPET_STATE_DIR}
fi

OS=$(/bin/bash ${PUPHPET_CORE_DIR}/shell/os-detect.sh ID)
CODENAME=$(/bin/bash ${PUPHPET_CORE_DIR}/shell/os-detect.sh CODENAME)
RELEASE=$(/bin/bash ${PUPHPET_CORE_DIR}/shell/os-detect.sh RELEASE)

if [[ -f ${PUPHPET_CORE_DIR}/shell/ascii-art/self-promotion.txt ]]; then
    cat ${PUPHPET_CORE_DIR}/shell/ascii-art/self-promotion.txt
    printf "\n"
    echo ""
fi

if [[ -f ${PUPHPET_STATE_DIR}/initial-setup ]]; then
    exit 0
fi

if [[ "${OS}" == 'debian' || "${OS}" == 'ubuntu' ]]; then
    apt-get update

    apt-get -y install iptables-persistent software-properties-common \
        python-software-properties curl git-core build-essential

    # Fixes https://github.com/mitchellh/vagrant/issues/1673
    # Fixes https://github.com/mitchellh/vagrant/issues/7368
    if [[ -d '/root' ]] && [[ -f '/root/.profile' ]]; then
        grep -q -E '^(mesg n \|\| true)$' /root/.profile && \
            sed -ri 's/^(mesg n \|\| true)$/tty -s \&\& mesg n/' /root/.profile
    fi
fi

if [[ "${OS}" == 'centos' ]]; then
    if [ "${RELEASE}" == 6 ]; then
        if [[ ! -f /etc/sysconfig/iptables ]]; then
            cat >/etc/sysconfig/iptables << 'EOL'
*filter
:INPUT ACCEPT [0:0]
COMMIT
EOL
            chmod 600 /etc/sysconfig/iptables
            cp /etc/sysconfig/iptables /etc/sysconfig/ip6tables
        fi

        EPEL='http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm'
    else
        EPEL='http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'
    fi

    yum -y --nogpgcheck install "${EPEL}"
    yum -y install centos-release-scl
    yum clean all
    yum -y check-update

    yum -y install curl git
    yum -y groupinstall 'Development Tools'
fi

# CentOS comes with tty enabled. RHEL has realized this is stupid, so we can
# also safely disable it in PuPHPet boxes.
if [[ ! -f ${PUPHPET_STATE_DIR}/disable-tty ]]; then
    perl -pi'~' -e 's@Defaults(\s+)requiretty@Defaults !requiretty@g' /etc/sudoers

    touch ${PUPHPET_STATE_DIR}/disable-tty
fi

touch ${PUPHPET_STATE_DIR}/initial-setup
