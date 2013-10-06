if [[ ! -f /puppet-updated ]]; then
    wget –quiet -O /tmp/puppet.deb http://apt.puppetlabs.com/puppetlabs-release-"$1".deb
    dpkg -i /tmp/puppet.deb
    apt-get update && apt-get install puppet
    touch /puppet-updated
fi
