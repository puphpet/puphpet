#!/bin/bash

OS=$(/bin/bash /vagrant/shell/os-detect.sh ID)
RELEASE=$(/bin/bash /vagrant/shell/os-detect.sh RELEASE)
CODENAME=$(/bin/bash /vagrant/shell/os-detect.sh CODENAME)

if [[ ! -f /.puphpet-stuff/update-puppet ]]; then
    if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
        echo "Downloading http://apt.puppetlabs.com/pool/${CODENAME}/main/p/puppet/puppet-common_3.3.2-1puppetlabs1_all.deb"
        wget --quiet --tries=5 --timeout=10 -O "/.puphpet-stuff/puppet-common_3.3.2-1puppetlabs1_all.deb" "http://apt.puppetlabs.com/pool/${CODENAME}/main/p/puppet/puppet-common_3.3.2-1puppetlabs1_all.deb"
        echo "Finished downloading http://apt.puppetlabs.com/pool/${CODENAME}/main/p/puppet/puppet-common_3.3.2-1puppetlabs1_all.deb"

        dpkg -i "/.puphpet-stuff/puppet-common_3.3.2-1puppetlabs1_all.deb" >/dev/null

        echo "Running update-puppet apt-get update"
        apt-get update >/dev/null
        echo "Finished running update-puppet apt-get update"

        echo "Updating Puppet to latest version"
        apt-get -y install puppet >/dev/null
        PUPPET_VERSION=$(puppet help | grep 'Puppet v')
        echo "Finished updating puppet to latest version: $PUPPET_VERSION"

        touch /.puphpet-stuff/update-puppet
        echo "Created empty file /.puphpet-stuff/update-puppet"
    elif [ "$OS" == 'centos' ]; then
        echo "Downloading https://yum.puppetlabs.com/el/${RELEASE}/dependencies/x86_64/ruby-rgen-0.6.5-1.el6.noarch.rpm"
        yum -y --nogpgcheck install "https://yum.puppetlabs.com/el/${RELEASE}/dependencies/x86_64/ruby-rgen-0.6.5-1.el6.noarch.rpm" >/dev/null
        echo "Finished downloading https://yum.puppetlabs.com/el/${RELEASE}/dependencies/x86_64/ruby-rgen-0.6.5-1.el6.noarch.rpm"

        echo "Downloading http://yum.puppetlabs.com/el/${RELEASE}/products/x86_64/puppet-3.3.2-1.el6.noarch.rpm"
        yum -y --nogpgcheck install "http://yum.puppetlabs.com/el/${RELEASE}/products/x86_64/puppet-3.3.2-1.el6.noarch.rpm" >/dev/null
        echo "Finished downloading http://yum.puppetlabs.com/el/${RELEASE}/products/x86_64/puppet-3.3.2-1.el6.noarch.rpm"

        echo "Running update-puppet yum update"
        yum -y update >/dev/null
        echo "Finished running update-puppet yum update"

        echo "Installing/Updating Puppet to latest version"
        yum -y install puppet >/dev/null
        PUPPET_VERSION=$(puppet help | grep 'Puppet v')
        echo "Finished installing/updating puppet to latest version: $PUPPET_VERSION"

        touch /.puphpet-stuff/update-puppet
        echo "Created empty file /.puphpet-stuff/update-puppet"
    fi
fi
