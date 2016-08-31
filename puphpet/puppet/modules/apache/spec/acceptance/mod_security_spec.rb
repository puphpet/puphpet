require 'spec_helper_acceptance'

describe 'apache::mod::security class', :unless => (UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) or (fact('osfamily') == 'Debian' and (fact('lsbdistcodename') == 'squeeze' or fact('lsbdistcodename') == 'lucid' or fact('lsbdistcodename') == 'precise'))) do
  case fact('osfamily')
  when 'Debian'
    mod_dir      = '/etc/apache2/mods-available'
    service_name = 'apache2'
    package_name = 'apache2'
  when 'RedHat'
    mod_dir      = '/etc/httpd/conf.d'
    service_name = 'httpd'
    package_name = 'httpd'
  end

  context "default mod_security config" do
    if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') =~ /(5|6)/
      it 'adds epel' do
        pp = "class { 'epel': }"
        apply_manifest(pp, :catch_failures => true)
      end
    end

    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '/var/www/html',
        }
        file { '/var/www/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end

    describe file("#{mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker modsec.example.com:80') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end

    it 'should block query with SQL' do
      shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
    end

  end #default mod_security config

  context "mod_security should allow disabling by vhost" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '/var/www/html',
        }
        file { '/var/www/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file("#{mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    it 'should block query with SQL' do
      shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port                 => '80',
          docroot              => '/var/www/html',
          modsec_disable_vhost => true,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end
  end #mod_security should allow disabling by vhost

  context "mod_security should allow disabling by ip" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '/var/www/html',
        }
        file { '/var/www/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file("#{mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    it 'should block query with SQL' do
      shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port               => '80',
          docroot            => '/var/www/html',
          modsec_disable_ips => [ '127.0.0.1' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker modsec.example.com:80') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end
  end #mod_security should allow disabling by ip

  context "mod_security should allow disabling by id" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '/var/www/html',
        }
        file { '/var/www/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
        file { '/var/www/html/index2.html':
          ensure  => file,
          content => 'Page 2',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file("#{mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    it 'should block query with SQL' do
      shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port               => '80',
          docroot            => '/var/www/html',
          modsec_disable_ids => [ '950007' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end

  end #mod_security should allow disabling by id


end #apache::mod::security class
