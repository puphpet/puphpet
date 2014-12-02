#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

function check_ruby_symlinks() {
    # Ruby or Gem not symlinked
    if [ ! -L '/usr/bin/ruby' ] || [ ! -L '/usr/bin/gem' ]; then
        rm -f '/.puphpet-stuff/install-ruby'

        return 0;
    fi

    RUBY_SYMLINK=$(ls -l /usr/bin/ruby);
    GEM_SYMLINK=$(ls -l /usr/bin/gem);

    # If ruby symlink is old-style pointing to /usr/local/rvm/wrappers/default/ruby
    if [ "grep '/usr/local/rvm/wrappers/default' ${RUBY_SYMLINK}" ]; then
        rm -f '/usr/bin/ruby'

        if [[ -f '/usr/local/rvm/rubies/ruby-1.9.3-p547/bin/ruby' ]]; then
            ln -s '/usr/local/rvm/rubies/ruby-1.9.3-p547/bin/ruby' '/usr/bin/ruby'
        elif [[ -f '/usr/local/rvm/rubies/ruby-1.9.3-p551/bin/ruby' ]]; then
            ln -s '/usr/local/rvm/rubies/ruby-1.9.3-p551/bin/ruby' '/usr/bin/ruby'
        else
            rm -f '/.puphpet-stuff/install-ruby'
        fi
    fi

    # If gem symlink is old-style pointing to /usr/local/rvm/wrappers/default/gem
    if [ "grep '/usr/local/rvm/wrappers/default' ${GEM_SYMLINK}" ]; then
        rm -f '/usr/bin/gem'

        if [[ -f '/usr/local/rvm/rubies/ruby-1.9.3-p547/bin/gem' ]]; then
            ln -s '/usr/local/rvm/rubies/ruby-1.9.3-p547/bin/gem' '/usr/bin/gem'
        elif [[ -f '/usr/local/rvm/rubies/ruby-1.9.3-p551/bin/gem' ]]; then
            ln -s '/usr/local/rvm/rubies/ruby-1.9.3-p551/bin/gem' '/usr/bin/gem'
        else
            rm -f '/.puphpet-stuff/install-ruby'
        fi
    fi
}

check_ruby_symlinks

if [[ -f '/.puphpet-stuff/install-ruby' ]]; then
    exit 0
fi

echo 'Installing Ruby 1.9.3 using RVM'

rm -rf /usr/local/rvm/rubies/ruby-1.9.3-p*

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
elif [[ "${OS}" == 'centos' ]]; then
    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
fi

curl -sSL https://get.rvm.io | bash -s stable --quiet-curl --ruby=1.9.3
source /usr/local/rvm/scripts/rvm

if [[ -f '/usr/bin/ruby' ]]; then
    mv /usr/bin/ruby /usr/bin/ruby-old
fi

if [[ -f '/usr/bin/gem' ]]; then
    mv /usr/bin/gem /usr/bin/gem-old
fi

rm -rf /usr/bin/ruby
rm -rf /usr/bin/gem

ln -s /usr/local/rvm/rubies/ruby-1.9.3-p*/bin/ruby /usr/bin/ruby
ln -s /usr/local/rvm/rubies/ruby-1.9.3-p*/bin/gem /usr/bin/gem

/usr/local/rvm/bin/rvm cleanup all

/usr/bin/gem update --system >/dev/null

touch '/.puphpet-stuff/install-ruby'

echo 'Finished install Ruby 1.9.3 using RVM'
