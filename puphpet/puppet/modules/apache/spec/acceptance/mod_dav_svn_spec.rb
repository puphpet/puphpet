require 'spec_helper_acceptance'

describe 'apache::mod::dav_svn class', :unless => (fact('operatingsystem') == 'OracleLinux' and fact('operatingsystemmajrelease') == '7') do
  case fact('osfamily')
  when 'Debian'
    mod_dir             = '/etc/apache2/mods-available'
    service_name        = 'apache2'
    if fact('operatingsystemmajrelease') == '6' or fact('operatingsystemmajrelease') == '10.04' or fact('operatingsystemrelease') == '10.04'
      authz_svn_load_file = 'dav_svn_authz_svn.load'
    else
      authz_svn_load_file = 'authz_svn.load'
    end
  when 'RedHat'
    mod_dir             = '/etc/httpd/conf.d'
    service_name        = 'httpd'
    authz_svn_load_file = 'dav_svn_authz_svn.load'
  when 'FreeBSD'
    mod_dir             = '/usr/local/etc/apache24/Modules'
    service_name        = 'apache24'
    authz_svn_load_file = 'dav_svn_authz_svn.load'
  end

  context "default dav_svn config" do
    it 'succeeds in puppeting dav_svn' do
      pp= <<-EOS
        class { 'apache': }
        include apache::mod::dav_svn
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file("#{mod_dir}/dav_svn.load") do
      it { is_expected.to contain "LoadModule dav_svn_module" }
    end
  end

  context "dav_svn with enabled authz_svn config" do
    it 'succeeds in puppeting dav_svn' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::dav_svn':
            authz_svn_enabled => true,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file("#{mod_dir}/#{authz_svn_load_file}") do
      it { is_expected.to contain "LoadModule authz_svn_module" }
    end
  end
end
