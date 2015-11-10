require "spec_helper_acceptance"

describe "rvm" do

  # host variables
  let(:osfamily) { fact("osfamily") }
  let(:osname) { fact("operatingsystem") }
  let(:osversion) { fact("operatingsystemrelease") }

  # rvm config
  let(:rvm_path) { "/usr/local/rvm/" }

  # ruby 1.9.3 config
  let(:ruby19_version) { "ruby-1.9.3-p547" } # chosen for RVM binary support across nodesets
  let(:ruby19_environment) { "#{rvm_path}environments/#{ruby19_version}" }
  let(:ruby19_bin) { "#{rvm_path}rubies/#{ruby19_version}/bin/" }
  let(:ruby19_gems) { "#{rvm_path}gems/#{ruby19_version}/gems/" }
  let(:ruby19_gemset) { "myproject" }
  let(:ruby19_and_gemset) { "#{ruby19_version}@#{ruby19_gemset}" }

  # ruby 2.0 config
  let(:ruby20_version) { "ruby-2.0.0-p481" } # chosen for RVM binary support across nodesets
  let(:ruby20_environment) { "#{rvm_path}environments/#{ruby20_version}" }
  let(:ruby20_bin) { "#{rvm_path}rubies/#{ruby20_version}/bin/" }
  let(:ruby20_gems) { "#{rvm_path}gems/#{ruby20_version}/gems/" }
  let(:ruby20_gemset) { "myproject" }
  let(:ruby20_and_gemset) { "#{ruby20_version}@#{ruby20_gemset}" }

  # passenger baseline configuration
  let(:service_name) {
    case osfamily
    when "Debian"
      "apache2"
    when "RedHat"
      "httpd"
    end
  }
  let(:mod_dir) {
    case osfamily
    when "Debian"
      "/etc/apache2/mods-available/"
    when "RedHat"
      "/etc/httpd/conf.d/"
    end
  }
  let(:rackapp_user) {
    case osfamily
    when "Debian"
      "www-data"
    when "RedHat"
      "apache"
    end
  }
  let(:rackapp_group) {
    case osfamily
    when "Debian"
      "www-data"
    when "RedHat"
      "apache"
    end
  }
  let(:conf_file) { "#{mod_dir}passenger.conf" }
  let(:load_file) { "#{mod_dir}passenger.load" }

  # baseline manifest
  let(:manifest) {
    <<-EOS
      if $::osfamily == 'RedHat' {
        class { 'epel':
          before => Class['rvm'],
        }
      }

      # ensure rvm doesn't timeout finding binary rubies
      class { 'rvm::rvmrc':
        max_time_flag => '20',
      } ->

      class { 'rvm': } ->
      rvm::system_user { 'vagrant': }
  EOS
  }

  it "rvm should install and configure system user" do
    # Run it twice and test for idempotency
    apply_manifest(manifest, :catch_failures => true)
    apply_manifest(manifest, :catch_changes => true)
    shell("/usr/local/rvm/bin/rvm list") do |r|
      r.stdout.should =~ Regexp.new(Regexp.escape("# No rvm rubies installed yet."))
      r.exit_code.should be_zero
    end
  end

  context "when installing rubies" do

    let(:manifest) {
      super() + <<-EOS
        rvm_system_ruby {
          '#{ruby19_version}':
            ensure      => 'present',
            default_use => false;
          '#{ruby20_version}':
            ensure      => 'present',
            default_use => false;
        }
      EOS
    }

    it "should install with no errors" do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it "should reflect installed rubies" do
      shell("/usr/local/rvm/bin/rvm list") do |r|
        r.stdout.should =~ Regexp.new(Regexp.escape("\n   #{ruby19_version}"))
        r.stdout.should =~ Regexp.new(Regexp.escape("\n   #{ruby20_version}"))
        r.exit_code.should be_zero
      end
    end

    context "and installing gems" do
      let(:gem_name) { "simple-rss" } # used because has no dependencies
      let(:gem_version) { "1.3.1" }

      let(:gemset_manifest) {
        manifest + <<-EOS
          rvm_gemset {
            '#{ruby19_and_gemset}':
              ensure  => present,
              require => Rvm_system_ruby['#{ruby19_version}'];
          }
          rvm_gem {
            '#{ruby19_and_gemset}/#{gem_name}':
              ensure  => '#{gem_version}',
              require => Rvm_gemset['#{ruby19_and_gemset}'];
          }
          rvm_gemset {
            '#{ruby20_and_gemset}':
              ensure  => present,
              require => Rvm_system_ruby['#{ruby20_version}'];
          }
          rvm_gem {
            '#{ruby20_and_gemset}/#{gem_name}':
              ensure  => '#{gem_version}',
              require => Rvm_gemset['#{ruby20_and_gemset}'];
          }
        EOS
      }

      it "should install with no errors" do
        apply_manifest(gemset_manifest, :catch_failures => true)
        apply_manifest(gemset_manifest, :catch_changes => true)
      end

      it "should reflect installed gems and gemsets" do
        shell("/usr/local/rvm/bin/rvm #{ruby19_version} gemset list") do |r|
          r.stdout.should =~ Regexp.new(Regexp.escape("\n=> (default)"))
          r.stdout.should =~ Regexp.new(Regexp.escape("\n   global"))
          r.stdout.should =~ Regexp.new(Regexp.escape("\n   #{ruby19_gemset}"))
          r.exit_code.should be_zero
        end

        shell("/usr/local/rvm/bin/rvm #{ruby20_version} gemset list") do |r|
          r.stdout.should =~ Regexp.new(Regexp.escape("\n=> (default)"))
          r.stdout.should =~ Regexp.new(Regexp.escape("\n   global"))
          r.stdout.should =~ Regexp.new(Regexp.escape("\n   #{ruby20_gemset}"))
          r.exit_code.should be_zero
        end
      end
    end
  end

  context "when installing jruby" do
    let(:jruby_version) { "jruby-1.7.6" }

    let(:manifest) {
      super() + <<-EOS
        rvm_system_ruby { '#{jruby_version}':
          ensure      => 'present',
          default_use => false;
        }
      EOS
    }

    it 'should install with no errors' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    it 'should reflect installed rubies' do
      shell("/usr/local/rvm/bin/rvm list") do |r|
        r.stdout.should =~ Regexp.new(Regexp.escape("\n   #{jruby_version}"))
        r.exit_code.should be_zero
      end
    end
  end

  context "when installing passenger 3.0.x" do

    let(:passenger_version) { "3.0.21" }
    let(:passenger_domain) { "passenger3.example.com" }

    let(:passenger_ruby) { "#{rvm_path}wrappers/#{ruby19_version}/ruby" }
    let(:passenger_root) { "#{ruby19_gems}passenger-#{passenger_version}" }
    # particular to 3.0.x (may or may not also work with 2.x?)
    let(:passenger_module_path) { "#{passenger_root}/ext/apache2/mod_passenger.so" }

    let(:manifest) { 
      super() + <<-EOS
        rvm_system_ruby {
          '#{ruby19_version}':
            ensure      => 'present',
            default_use => false,
        }
        class { 'apache':
          service_enable => false, # otherwise detects changes in 2nd run in ubuntu and docker
        }
        class { 'rvm::passenger::apache':
          version            => '#{passenger_version}',
          ruby_version       => '#{ruby19_version}',
          mininstances       => '3',
          maxinstancesperapp => '0',
          maxpoolsize        => '30',
          spawnmethod        => 'smart-lv2',
        }
        /* a simple ruby rack 'hello world' app */
        file { '/var/www/passenger':
          ensure  => directory,
          owner   => '#{rackapp_user}',
          group   => '#{rackapp_group}',
          require => Class['rvm::passenger::apache'],
        }
        file { '/var/www/passenger/config.ru':
          ensure  => file,
          owner   => '#{rackapp_user}',
          group   => '#{rackapp_group}',
          content => "app = proc { |env| [200, { \\"Content-Type\\" => \\"text/html\\" }, [\\"hello <b>world</b>\\"]] }\\nrun app",
          require => File['/var/www/passenger'] ,
        }
        apache::vhost { '#{passenger_domain}':
          port    => '80',
          docroot => '/var/www/passenger/public',
          docroot_group => '#{rackapp_group}' ,
          docroot_owner => '#{rackapp_user}' ,
          custom_fragment => "PassengerRuby  #{passenger_ruby}\\nRailsEnv  development" ,
          default_vhost => true ,
          require => File['/var/www/passenger/config.ru'] ,
        }
      EOS
    }

    it "should install with no errors" do
      # Run it twice and test for idempotency
      apply_manifest(manifest, :catch_failures => true)
      # swapping expectations under Ubuntu 12.04, 14.04 - apache2-prefork-dev is being purged/restored by puppetlabs/apache, which is beyond the scope of this module
      if osname == 'Ubuntu' && ['12.04', '14.04'].include?(osversion)
        apply_manifest(manifest, :expect_changes => true)
      else
        apply_manifest(manifest, :catch_changes => true)
      end

      shell("/usr/local/rvm/bin/rvm #{ruby19_version} do #{ruby19_bin}gem list passenger | grep \"passenger (#{passenger_version})\"").exit_code.should be_zero
    end

    it "should be running" do
      service(service_name) do |s|
        s.should_not be_enabled
        s.should be_running
      end
    end

    it "should answer" do
      shell("/usr/bin/curl localhost:80") do |r|
        r.stdout.should =~ /^hello <b>world<\/b>$/
        r.exit_code.should == 0
      end
    end

    it "should output status via passenger-status" do
      shell("rvmsudo_secure_path=1 /usr/local/rvm/bin/rvm #{ruby19_version} do passenger-status") do |r|
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

    it "module loading should be configured as expected" do
      file(load_file) do |f|
        f.should contain "LoadModule passenger_module #{passenger_module_path}"
      end
    end

    it "module behavior should be configured as expected" do
      file(conf_file) do |f|
        f.should contain "PassengerRoot \"#{passenger_root}\""
        f.should contain "PassengerRuby \"#{passenger_ruby}\""
      end
    end

  end

  context "when installing passenger 4.0.x" do

    let(:passenger_version) { "4.0.46" }
    let(:passenger_domain) { "passenger4.example.com" }

    let(:passenger_ruby) { "#{rvm_path}wrappers/#{ruby20_version}/ruby" }
    let(:passenger_root) { "#{ruby20_gems}passenger-#{passenger_version}" }
    # particular to passenger 4.0.x
    let(:passenger_module_path) { "#{passenger_root}/buildout/apache2/mod_passenger.so" }

    let(:manifest) {
      super() + <<-EOS
        rvm_system_ruby {
          '#{ruby20_version}':
            ensure      => 'present',
            default_use => false,
        }
        class { 'apache':
          service_enable => false, # otherwise detects changes in 2nd run in ubuntu and docker
        }
        class { 'rvm::passenger::apache':
          version            => '#{passenger_version}',
          ruby_version       => '#{ruby20_version}',
          mininstances       => '3',
          maxinstancesperapp => '0',
          maxpoolsize        => '30',
          spawnmethod        => 'smart-lv2',
        }
        /* a simple ruby rack 'hello world' app */
        file { '/var/www/passenger':
          ensure  => directory,
          owner   => '#{rackapp_user}',
          group   => '#{rackapp_group}',
          require => Class['rvm::passenger::apache'],
        }
        file { '/var/www/passenger/config.ru':
          ensure  => file,
          owner   => '#{rackapp_user}',
          group   => '#{rackapp_group}',
          content => "app = proc { |env| [200, { \\"Content-Type\\" => \\"text/html\\" }, [\\"hello <b>world</b>\\"]] }\\nrun app",
          require => File['/var/www/passenger'] ,
        }
        apache::vhost { '#{passenger_domain}':
          port    => '80',
          docroot => '/var/www/passenger/public',
          docroot_group => '#{rackapp_group}' ,
          docroot_owner => '#{rackapp_user}' ,
          custom_fragment => "PassengerRuby  #{passenger_ruby}\\nRailsEnv  development" ,
          default_vhost => true ,
          require => File['/var/www/passenger/config.ru'] ,
        }
      EOS
    }

    it "should install with no errors" do
      # Run it twice and test for idempotency
      apply_manifest(manifest, :catch_failures => true)
      # swapping expectations under Ubuntu 14.04 - apache2-prefork-dev is being purged/restored by puppetlabs/apache, which is beyond the scope of this module
      if osname == 'Ubuntu' && ['14.04'].include?(osversion)
        apply_manifest(manifest, :expect_changes => true)
      else
        apply_manifest(manifest, :catch_changes => true)
      end

      shell("/usr/local/rvm/bin/rvm #{ruby20_version} do #{ruby20_bin}gem list passenger | grep \"passenger (#{passenger_version})\"").exit_code.should be_zero
    end

    it "should be running" do
      service(service_name) do |s|
        s.should_not be_enabled
        s.should be_running
      end
    end

    it "should answer" do
      shell("/usr/bin/curl localhost:80") do |r|
        r.stdout.should =~ /^hello <b>world<\/b>$/
        r.exit_code.should == 0
      end
    end

    it "should output status via passenger-status" do
      shell("rvmsudo_secure_path=1 /usr/local/rvm/bin/rvm #{ruby20_version} do passenger-status") do |r|
        # spacing may vary
        r.stdout.should =~ /[\-]+ General information [\-]+/
        r.stdout.should =~ /Max pool size \: [0-9]+/
        r.stdout.should =~ /Processes     \: [0-9]+/
        r.stdout.should =~ /Requests in top\-level queue \: [0-9]+/
        r.stdout.should =~ /[\-]+ Application groups [\-]+/
        # the following will only appear after a request has been made, as in "should answer to" above
        r.stdout.should =~ /App root\: \/var\/www\/passenger/
        r.stdout.should =~ /Requests in queue\: [0-9]+/
        r.exit_code.should == 0
      end
    end

    it "module loading should be configured as expected" do
      file(load_file) do |f|
        f.should contain "LoadModule passenger_module #{passenger_module_path}"
      end
    end

    it "module behavior should be configured as expected" do
      file(conf_file) do |f|
        f.should contain "PassengerRoot \"#{passenger_root}\""
        f.should contain "PassengerRuby \"#{passenger_ruby}\""
      end
    end

  end

end
