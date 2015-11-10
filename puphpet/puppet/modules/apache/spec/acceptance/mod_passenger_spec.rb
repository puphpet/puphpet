require 'spec_helper_acceptance'

describe 'apache::mod::passenger class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  case fact('osfamily')
  when 'Debian'
    service_name = 'apache2'
    mod_dir = '/etc/apache2/mods-available/'
    conf_file = "#{mod_dir}passenger.conf"
    load_file = "#{mod_dir}zpassenger.load"

    case fact('operatingsystem')
    when 'Ubuntu'
      case fact('lsbdistrelease')
      when '10.04'
        passenger_root = '/usr'
        passenger_ruby = '/usr/bin/ruby'
      when '12.04'
        passenger_root = '/usr'
        passenger_ruby = '/usr/bin/ruby'
      when '14.04'
        passenger_root         = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
        passenger_ruby         = '/usr/bin/ruby'
        passenger_default_ruby = '/usr/bin/ruby'
      else
        # This may or may not work on Ubuntu releases other than the above
        passenger_root = '/usr'
        passenger_ruby = '/usr/bin/ruby'
      end
    when 'Debian'
      case fact('lsbdistcodename')
      when 'wheezy'
        passenger_root = '/usr'
        passenger_ruby = '/usr/bin/ruby'
      when 'jessie'
        passenger_root         = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
        passenger_ruby         = '/usr/bin/ruby'
        passenger_default_ruby = '/usr/bin/ruby'
      else
        # This may or may not work on Debian releases other than the above
        passenger_root = '/usr'
        passenger_ruby = '/usr/bin/ruby'
      end
    end

    passenger_module_path = '/usr/lib/apache2/modules/mod_passenger.so'
    rackapp_user = 'www-data'
    rackapp_group = 'www-data'
  when 'RedHat'
    service_name = 'httpd'
    mod_dir = '/etc/httpd/conf.d/'
    conf_file = "#{mod_dir}passenger.conf"
    load_file = "#{mod_dir}zpassenger.load"
    # sometimes installs as 3.0.12, sometimes as 3.0.19 - so just check for the stable part
    passenger_root = '/usr/lib/ruby/gems/1.8/gems/passenger-3.0.1'
    passenger_ruby = '/usr/bin/ruby'
    passenger_tempdir = '/var/run/rubygem-passenger'
    passenger_module_path = 'modules/mod_passenger.so'
    rackapp_user = 'apache'
    rackapp_group = 'apache'
  end

  pp_rackapp = <<-EOS
          /* a simple ruby rack 'hellow world' app */
          file { '/var/www/passenger':
            ensure  => directory,
            owner   => '#{rackapp_user}',
            group   => '#{rackapp_group}',
            require => Class['apache::mod::passenger'],
          }
          file { '/var/www/passenger/config.ru':
            ensure  => file,
            owner   => '#{rackapp_user}',
            group   => '#{rackapp_group}',
            content => "app = proc { |env| [200, { \\"Content-Type\\" => \\"text/html\\" }, [\\"hello <b>world</b>\\"]] }\\nrun app",
            require => File['/var/www/passenger'] ,
          }
          apache::vhost { 'passenger.example.com':
            port    => '80',
            docroot => '/var/www/passenger/public',
            docroot_group => '#{rackapp_group}' ,
            docroot_owner => '#{rackapp_user}' ,
            custom_fragment => "PassengerRuby  #{passenger_ruby}\\nRailsEnv  development" ,
            require => File['/var/www/passenger/config.ru'] ,
          }
          host { 'passenger.example.com': ip => '127.0.0.1', }
  EOS

  case fact('osfamily')
  when 'Debian'
    context "default passenger config" do
      it 'succeeds in puppeting passenger' do
        pp = <<-EOS
          /* stock apache and mod_passenger */
          class { 'apache': }
          class { 'apache::mod::passenger': }
          #{pp_rackapp}
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe service(service_name) do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe file(conf_file) do
        it { is_expected.to contain "PassengerRoot \"#{passenger_root}\"" }

        case fact('operatingsystem')
        when 'Ubuntu'
          case fact('lsbdistrelease')
          when '10.04'
            it { is_expected.to contain "PassengerRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerDefaultRuby/" }
          when '12.04'
            it { is_expected.to contain "PassengerRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerDefaultRuby/" }
          when '14.04'
            it { is_expected.to contain "PassengerDefaultRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerRuby/" }
          else
            # This may or may not work on Ubuntu releases other than the above
            it { is_expected.to contain "PassengerRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerDefaultRuby/" }
          end
        when 'Debian'
          case fact('lsbdistcodename')
          when 'wheezy'
            it { is_expected.to contain "PassengerRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerDefaultRuby/" }
          when 'jessie'
            it { is_expected.to contain "PassengerDefaultRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerRuby/" }
          else
            # This may or may not work on Debian releases other than the above
            it { is_expected.to contain "PassengerRuby \"#{passenger_ruby}\"" }
            it { is_expected.not_to contain "/PassengerDefaultRuby/" }
          end
        end
      end

      describe file(load_file) do
        it { is_expected.to contain "LoadModule passenger_module #{passenger_module_path}" }
      end

      it 'should output status via passenger-memory-stats' do
        shell("PATH=/usr/bin:$PATH /usr/sbin/passenger-memory-stats") do |r|
          expect(r.stdout).to match(/Apache processes/)
          expect(r.stdout).to match(/Nginx processes/)
          expect(r.stdout).to match(/Passenger processes/)

          # passenger-memory-stats output on newer Debian/Ubuntu verions do not contain
          # these two lines
          unless ((fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemrelease') == '14.04') or
                 (fact('operatingsystem') == 'Debian' && fact('operatingsystemrelease') == '8.0'))
            expect(r.stdout).to match(/### Processes: [0-9]+/)
            expect(r.stdout).to match(/### Total private dirty RSS: [0-9\.]+ MB/)
          end

          expect(r.exit_code).to eq(0)
        end
      end

      # passenger-status fails under stock ubuntu-server-12042-x64 + mod_passenger,
      # even when the passenger process is successfully installed and running
      unless fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemrelease') == '12.04'
        it 'should output status via passenger-status' do
          # xml output not available on ubunutu <= 10.04, so sticking with default pool output
          shell("PATH=/usr/bin:$PATH /usr/sbin/passenger-status") do |r|
            # spacing may vary
            expect(r.stdout).to match(/[\-]+ General information [\-]+/)
            if fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemrelease') == '14.04'
              expect(r.stdout).to match(/Max pool size[ ]+: [0-9]+/)
              expect(r.stdout).to match(/Processes[ ]+: [0-9]+/)
              expect(r.stdout).to match(/Requests in top-level queue[ ]+: [0-9]+/)
            else
              expect(r.stdout).to match(/max[ ]+= [0-9]+/)
              expect(r.stdout).to match(/count[ ]+= [0-9]+/)
              expect(r.stdout).to match(/active[ ]+= [0-9]+/)
              expect(r.stdout).to match(/inactive[ ]+= [0-9]+/)
              expect(r.stdout).to match(/Waiting on global queue: [0-9]+/)
            end

            expect(r.exit_code).to eq(0)
          end
        end
      end

      it 'should answer to passenger.example.com' do
        shell("/usr/bin/curl passenger.example.com:80") do |r|
          expect(r.stdout).to match(/^hello <b>world<\/b>$/)
          expect(r.exit_code).to eq(0)
        end
      end

    end

  when 'RedHat'
    # no fedora 18 passenger package yet, and rhel5 packages only exist for ruby 1.8.5
    unless (fact('operatingsystem') == 'Fedora' and fact('operatingsystemrelease').to_f >= 18) or (fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '5' and fact('rubyversion') != '1.8.5')

      if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '7'
        pending('test passenger - RHEL7 packages don\'t exist')
      else
        context "default passenger config" do
          it 'succeeds in puppeting passenger' do
            pp = <<-EOS
              /* EPEL and passenger repositories */
              class { 'epel': }
              exec { 'passenger.repo GPG key':
                command => '/usr/bin/curl -o /etc/yum.repos.d/RPM-GPG-KEY-stealthymonkeys.asc http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc',
                creates => '/etc/yum.repos.d/RPM-GPG-KEY-stealthymonkeys.asc',
              }
              file { 'passenger.repo GPG key':
                ensure  => file,
                path    => '/etc/yum.repos.d/RPM-GPG-KEY-stealthymonkeys.asc',
                require => Exec['passenger.repo GPG key'],
              }
              epel::rpm_gpg_key { 'passenger.stealthymonkeys.com':
                path    => '/etc/yum.repos.d/RPM-GPG-KEY-stealthymonkeys.asc',
                require => [
                  Class['epel'],
                  File['passenger.repo GPG key'],
                ]
              }
              $releasever_string = $operatingsystem ? {
                'Scientific' => '6',
                default      => '$releasever',
              }
              yumrepo { 'passenger':
                baseurl         => "http://passenger.stealthymonkeys.com/rhel/${releasever_string}/\\$basearch" ,
                descr           => "Red Hat Enterprise ${releasever_string} - Phusion Passenger",
                enabled         => 1,
                gpgcheck        => 1,
                gpgkey          => 'http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc',
                mirrorlist      => 'http://passenger.stealthymonkeys.com/rhel/mirrors',
                require => [
                  Epel::Rpm_gpg_key['passenger.stealthymonkeys.com'],
                ],
              }
              /* apache and mod_passenger */
              class { 'apache':
                  require => [
                    Class['epel'],
                ],
              }
              class { 'apache::mod::passenger':
                require => [
                  Yumrepo['passenger']
                ],
              }
              #{pp_rackapp}
            EOS
            apply_manifest(pp, :catch_failures => true)
          end

          describe service(service_name) do
            it { is_expected.to be_enabled }
            it { is_expected.to be_running }
          end

          describe file(conf_file) do
            it { is_expected.to contain "PassengerRoot #{passenger_root}" }
            it { is_expected.to contain "PassengerRuby #{passenger_ruby}" }
            it { is_expected.to contain "PassengerTempDir #{passenger_tempdir}" }
          end

          describe file(load_file) do
            it { is_expected.to contain "LoadModule passenger_module #{passenger_module_path}" }
          end

          it 'should output status via passenger-memory-stats' do
            shell("/usr/bin/passenger-memory-stats", :pty => true) do |r|
              expect(r.stdout).to match(/Apache processes/)
              expect(r.stdout).to match(/Nginx processes/)
              expect(r.stdout).to match(/Passenger processes/)
              expect(r.stdout).to match(/### Processes: [0-9]+/)
              expect(r.stdout).to match(/### Total private dirty RSS: [0-9\.]+ MB/)

              expect(r.exit_code).to eq(0)
            end
          end

          it 'should output status via passenger-status' do
            shell("PASSENGER_TMPDIR=/var/run/rubygem-passenger /usr/bin/passenger-status") do |r|
              # spacing may vary
              r.stdout.should =~ /[\-]+ General information [\-]+/
              r.stdout.should =~ /max[ ]+= [0-9]+/
              r.stdout.should =~ /count[ ]+= [0-9]+/
              r.stdout.should =~ /active[ ]+= [0-9]+/
              r.stdout.should =~ /inactive[ ]+= [0-9]+/
              r.stdout.should =~ /Waiting on global queue: [0-9]+/

              r.exit_code.should == 0
            end
          end

          it 'should answer to passenger.example.com' do
            shell("/usr/bin/curl passenger.example.com:80") do |r|
              r.stdout.should =~ /^hello <b>world<\/b>$/
              r.exit_code.should == 0
            end
          end
        end
      end
    end
  end
end
