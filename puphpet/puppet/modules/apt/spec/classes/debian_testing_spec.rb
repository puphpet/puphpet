require 'spec_helper'
describe 'apt::debian::testing', :type => :class do
  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
  it {
    should contain_apt__source("debian_testing").with({
      "location"            => "http://debian.mirror.iweb.ca/debian/",
      "release"             => "testing",
      "repos"               => "main contrib non-free",
      "required_packages"   => "debian-keyring debian-archive-keyring",
      "key"                 => "A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553",
      "key_server"          => "subkeys.pgp.net",
      "pin"                 => "-10"
    })
  }
end
