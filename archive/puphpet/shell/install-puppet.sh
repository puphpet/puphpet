#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

PUPHPET_CORE_DIR=/opt/puphpet
PUPHPET_STATE_DIR=/opt/puphpet-state

OS=$(/bin/bash "${PUPHPET_CORE_DIR}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${PUPHPET_CORE_DIR}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${PUPHPET_CORE_DIR}/shell/os-detect.sh" CODENAME)

if [[ ! -f "${PUPHPET_STATE_DIR}/install-puppet" ]]; then
    if [[ "${OS}" == 'debian' || "${OS}" == 'ubuntu' ]]; then
        wget --quiet --tries=5 --connect-timeout=10 \
            -O ${PUPHPET_STATE_DIR}/puppetlabs.gpg \
            https://apt.puppetlabs.com/pubkey.gpg
        apt-key add ${PUPHPET_STATE_DIR}/puppetlabs.gpg

        URL="https://apt.puppetlabs.com/puppet5-release-${CODENAME}.deb"
        wget --quiet --tries=5 --connect-timeout=10 \
            -O "${PUPHPET_STATE_DIR}/puppet5-release-${CODENAME}.deb" \
            ${URL}
        dpkg -i "${PUPHPET_STATE_DIR}/puppet5-release-${CODENAME}.deb"
        apt-get update
        apt-get -y install puppet-agent=5.3.*

        cat >/etc/apt/preferences.d/puppet-agent << 'EOL'
Package: puppet-agent
Pin: version 5.3.*
Pin-Priority: 1002
EOL
    fi

    if [[ "${OS}" == 'centos' ]]; then
        rpm --import https://yum.puppetlabs.com/RPM-GPG-KEY-puppet
        rpm -Uvh "https://yum.puppetlabs.com/puppet5/puppet5-release-el-${RELEASE}.noarch.rpm"
        yum -y install yum-plugin-versionlock puppet-agent-5.3*
        yum versionlock add puppet-agent
    fi

    rm -f /usr/bin/puppet
    ln -s /opt/puppetlabs/bin/puppet /usr/bin/puppet
    touch "${PUPHPET_STATE_DIR}/install-puppet"
fi

GEM=/opt/puppetlabs/puppet/bin/gem

if [[ ! -f "${PUPHPET_STATE_DIR}/gem_path" ]]; then
    GEM_PATH=$(${GEM} env gemdir)
    echo "${GEM_PATH}" > "${PUPHPET_STATE_DIR}/gem_path"
fi

GEM_PATH=$(cat "${PUPHPET_STATE_DIR}/gem_path")

if ! (${GEM} list deep_merge | grep -q 'deep_merge'); then
    ${GEM} install deep_merge -v 1.2.1 --no-ri --no-rdoc
fi

if ! (${GEM} list activesupport | grep -q 'activesupport'); then
    ${GEM} install activesupport -v 5.1.4 --no-ri --no-rdoc
fi

if ! (${GEM} list vine | grep -q 'vine'); then
    ${GEM} install vine -v 0.4 --no-ri --no-rdoc
fi
