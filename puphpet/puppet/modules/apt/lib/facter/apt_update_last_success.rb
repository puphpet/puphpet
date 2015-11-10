require 'facter'

#This is derived from the file /var/lib/apt/periodic/update-success-stamp
# This is generated upon a successful apt-get update run natively in ubuntu.
# the Puppetlabs-apt module deploys this same functionality for other debian-ish OSes
Facter.add('apt_update_last_success') do
  confine :osfamily => 'Debian'
  setcode do
    if File.exists?('/var/lib/apt/periodic/update-success-stamp')
      #get epoch time
      lastsuccess = File.mtime('/var/lib/apt/periodic/update-success-stamp').to_i
      lastsuccess
    else
      lastsuccess = -1
      lastsuccess
    end
  end
end
