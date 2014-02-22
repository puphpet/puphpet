#!/bin/bash

VAGRANT_CORE_FOLDER=$(cat "/.puphpet-stuff/vagrant-core-folder.txt")

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/

$(which git > /dev/null 2>&1)
FOUND_GIT=$?

if [ "${FOUND_GIT}" -ne '0' ] && [ ! -f /.puphpet-stuff/librarian-puppet-installed ]; then
    $(which apt-get > /dev/null 2>&1)
    FOUND_APT=$?
    $(which yum > /dev/null 2>&1)
    FOUND_YUM=$?
    $(which pacman > /dev/null 2>&1)
    FOUND_PACMAN=$?

    echo 'Installing git'

    if [ "${FOUND_YUM}" -eq '0' ]; then
        yum -q -y makecache
        yum -q -y install git
    elif [ "${FOUND_APT}" -eq '0' ]; then
        apt-get -q -y install git-core >/dev/null
    elif [ "${FOUND_PACMAN}" -eq '0' ]; then
        pacman -S git --noconfirm >/dev/null
    fi

    echo 'Finished installing git'
fi

if [[ ! -d "${PUPPET_DIR}" ]]; then
    mkdir -p "${PUPPET_DIR}"
    echo "Created directory ${PUPPET_DIR}"
fi

cp "${VAGRANT_CORE_FOLDER}/puppet/Puppetfile" "${PUPPET_DIR}"
echo "Copied Puppetfile"

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    if [[ ! -f /.puphpet-stuff/librarian-base-packages ]]; then
        echo 'Installing base packages for librarian'
        apt-get install -y build-essential ruby-dev >/dev/null
        echo 'Finished installing base packages for librarian'

        touch /.puphpet-stuff/librarian-base-packages
    fi
fi

if [ "${OS}" == 'ubuntu' ]; then
    if [[ ! -f /.puphpet-stuff/librarian-libgemplugin-ruby ]]; then
        echo 'Updating libgemplugin-ruby (Ubuntu only)'
        apt-get install -y libgemplugin-ruby >/dev/null
        echo 'Finished updating libgemplugin-ruby (Ubuntu only)'

        touch /.puphpet-stuff/librarian-libgemplugin-ruby
    fi

    if [ "${CODENAME}" == 'lucid' ] && [ ! -f /.puphpet-stuff/librarian-rubygems-update ]; then
        echo 'Updating rubygems (Ubuntu Lucid only)'
        echo 'Ignore all "conflicting chdir" errors!'
        gem install rubygems-update >/dev/null
        /var/lib/gems/1.8/bin/update_rubygems >/dev/null
        echo 'Finished updating rubygems (Ubuntu Lucid only)'

        touch /.puphpet-stuff/librarian-rubygems-update
    fi
fi

if [[ ! -f /.puphpet-stuff/librarian-puppet-installed ]]; then

    echo 'Installing librarian-puppet'
    if [ "${OS}" == 'arch' ]; then
        if [ -f /usr/bin/yaourt ]; then
            yaourt -S librarian-puppet --noconfirm --needed &>/dev/null
        else
            CURRENT_PATH=$(pwd)
            cd /tmp/

            wget -q https://aur.archlinux.org/packages/li/librarian-puppet/librarian-puppet.tar.gz
            
            tar xfz librarian-puppet.tar.gz

            cd librarian-puppet
            makepkg -si --noconfrim --needed &>/dev/null

            rm -rf librarian-puppet
            rm librarian-puppet.tar.gz

            cd $CURRENT_PATH
        fi
    else
        gem install librarian-puppet >/dev/null
    fi
    echo 'Finished installing librarian-puppet'

    echo 'Running initial librarian-puppet'
    cd "${PUPPET_DIR}" && librarian-puppet install --clean >/dev/null
    echo 'Finished running initial librarian-puppet'

    touch /.puphpet-stuff/librarian-puppet-installed
else
    echo 'Running update librarian-puppet'
    cd "${PUPPET_DIR}" && librarian-puppet update >/dev/null
    echo 'Finished running update librarian-puppet'
fi

echo "Replacing puppetlabs-git module with custom"
rm -rf /etc/puppet/modules/git
git clone https://github.com/puphpet/puppetlabs-git.git /etc/puppet/modules/git
echo "Finished replacing puppetlabs-git module with custom"
