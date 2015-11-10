require 'spec_helper'

# Helper function for testing the contents of `status.conf`
def status_conf_spec(allow_from, extended_status, status_path)
  it do
    is_expected.to contain_file("status.conf").with_content(
      "<Location #{status_path}>\n"\
      "    SetHandler server-status\n"\
      "    Order deny,allow\n"\
      "    Deny from all\n"\
      "    Allow from #{Array(allow_from).join(' ')}\n"\
      "</Location>\n"\
      "ExtendedStatus #{extended_status}\n"\
      "\n"\
      "<IfModule mod_proxy.c>\n"\
      "    # Show Proxy LoadBalancer status in mod_status\n"\
      "    ProxyStatus On\n"\
      "</IfModule>\n"
    )
  end
end

describe 'apache::mod::status', :type => :class do
  let :pre_condition do
    'include apache'
  end

  context "on a Debian OS with default params" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    it { is_expected.to contain_apache__mod("status") }

    status_conf_spec(["127.0.0.1", "::1"], "On", "/server-status")

    it { is_expected.to contain_file("status.conf").with({
      :ensure => 'file',
      :path   => '/etc/apache2/mods-available/status.conf',
    } ) }

    it { is_expected.to contain_file("status.conf symlink").with({
      :ensure => 'link',
      :path   => '/etc/apache2/mods-enabled/status.conf',
    } ) }

  end

  context "on a RedHat OS with default params" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    it { is_expected.to contain_apache__mod("status") }

    status_conf_spec(["127.0.0.1", "::1"], "On", "/server-status")

    it { is_expected.to contain_file("status.conf").with_path("/etc/httpd/conf.d/status.conf") }

  end

  context "with custom parameters $allow_from => ['10.10.10.10','11.11.11.11'], $extended_status => 'Off', $status_path => '/custom-status'" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    let :params do
      {
        :allow_from => ['10.10.10.10','11.11.11.11'],
        :extended_status => 'Off',
        :status_path => '/custom-status',
      }
    end

    status_conf_spec(["10.10.10.10", "11.11.11.11"], "Off", "/custom-status")

  end

  context "with valid parameter type $allow_from => ['10.10.10.10']" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    let :params do
      { :allow_from => ['10.10.10.10'] }
    end
    it 'should expect to succeed array validation' do
      expect {
        is_expected.to contain_file("status.conf")
      }.not_to raise_error()
    end
  end

  context "with invalid parameter type $allow_from => '10.10.10.10'" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    let :params do
      { :allow_from => '10.10.10.10' }
    end
    it 'should expect to fail array validation' do
      expect {
        is_expected.to contain_file("status.conf")
      }.to raise_error(Puppet::Error)
    end
  end

  # Only On or Off are valid options
  ['On', 'Off'].each do |valid_param|
    context "with valid value $extended_status => '#{valid_param}'" do
      let :facts do
        {
          :osfamily               => 'Debian',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :lsbdistcodename        => 'squeeze',
          :operatingsystem        => 'Debian',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do
        { :extended_status => valid_param }
      end
      it 'should expect to succeed regular expression validation' do
        expect {
          is_expected.to contain_file("status.conf")
        }.not_to raise_error()
      end
    end
  end

  ['Yes', 'No'].each do |invalid_param|
    context "with invalid value $extended_status => '#{invalid_param}'" do
      let :facts do
        {
          :osfamily               => 'Debian',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'Debian',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do
        { :extended_status => invalid_param }
      end
      it 'should expect to fail regular expression validation' do
        expect {
          is_expected.to contain_file("status.conf")
        }.to raise_error(Puppet::Error)
      end
    end
  end

end
