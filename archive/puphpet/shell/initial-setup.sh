#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet
PUPHPET_STATE_DIR=/opt/puphpet-state

# Run from Vagrant CLI
if [[ -d /vagrant ]]; then
    if [[ ! -L ${PUPHPET_CORE_DIR} ]]; then
        ln -s /vagrant/puphpet ${PUPHPET_CORE_DIR}
    fi

    # Run on local VM
    if [[ -d /.puphpet-stuff ]] && [[ ! -L ${PUPHPET_STATE_DIR} ]]; then
        ln -s /.puphpet-stuff ${PUPHPET_STATE_DIR}
    elif [[ ! -d ${PUPHPET_STATE_DIR} ]]; then
        mkdir ${PUPHPET_STATE_DIR}
    fi
else
    if [[ ! -d ${PUPHPET_CORE_DIR} ]]; then
        mkdir ${PUPHPET_CORE_DIR}
    fi

    if [[ ! -d ${PUPHPET_STATE_DIR} ]]; then
        mkdir ${PUPHPET_STATE_DIR}
    fi
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
    wget --quiet --tries=5 --connect-timeout=10 \
        -O ${PUPHPET_STATE_DIR}/puppetlabs.gpg \
        https://apt.puppetlabs.com/pubkey.gpg
    apt-key add ${PUPHPET_STATE_DIR}/puppetlabs.gpg

    apt-get update

    apt-get -y install anacron iptables-persistent software-properties-common \
        python-software-properties curl git-core build-essential

    # Anacron configuration
    cat >/etc/cron.weekly/autoupdt << 'EOL'
#!/bin/bash

apt-get update
apt-get autoclean
EOL

    # Fixes https://github.com/mitchellh/vagrant/issues/1673
    # Fixes https://github.com/mitchellh/vagrant/issues/7368
    if [[ -d '/root' ]] && [[ -f '/root/.profile' ]]; then
        grep -q -E '^(mesg n \|\| true)$' /root/.profile && \
            sed -ri 's/^(mesg n \|\| true)$/tty -s \&\& mesg n/' /root/.profile
    fi
fi

if [[ "${OS}" == 'centos' ]]; then
    perl -p -i -e 's@enabled=1@enabled=0@gi' /etc/yum/pluginconf.d/fastestmirror.conf

    if [ "${RELEASE}" == 6 ]; then
        EL_REPO='http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm'
        EPEL='http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm'
    else
        EL_REPO='http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm'
        EPEL='http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm'
    fi

    yum -y --nogpgcheck install "${EL_REPO}"
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
