require 'spec_helper'

describe 'apache', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :lsbdistcodename        => 'squeeze',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_package("httpd").with(
      'notify' => 'Class[Apache::Service]',
      'ensure' => 'installed'
      )
    }
    it { is_expected.to contain_user("www-data") }
    it { is_expected.to contain_group("www-data") }
    it { is_expected.to contain_class("apache::service") }
    it { is_expected.to contain_file("/var/www").with(
      'ensure'  => 'directory'
      )
    }
    it { is_expected.to contain_file("/etc/apache2/sites-enabled").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
      )
    }
    it { is_expected.to contain_file("/etc/apache2/mods-enabled").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
      )
    }
    it { is_expected.to contain_file("/etc/apache2/mods-available").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'false',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
      )
    }
    it { is_expected.to contain_concat("/etc/apache2/ports.conf").with(
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Class[Apache::Service]'
      )
    }
    # Assert that load files are placed and symlinked for these mods, but no conf file.
    [
      'auth_basic',
      'authn_file',
      'authz_default',
      'authz_groupfile',
      'authz_host',
      'authz_user',
      'dav',
      'env'
    ].each do |modname|
      it { is_expected.to contain_file("#{modname}.load").with(
        'path'   => "/etc/apache2/mods-available/#{modname}.load",
        'ensure' => 'file'
      ) }
      it { is_expected.to contain_file("#{modname}.load symlink").with(
        'path'   => "/etc/apache2/mods-enabled/#{modname}.load",
        'ensure' => 'link',
        'target' => "/etc/apache2/mods-available/#{modname}.load"
      ) }
      it { is_expected.not_to contain_file("#{modname}.conf") }
      it { is_expected.not_to contain_file("#{modname}.conf symlink") }
    end

    context "with Apache version < 2.4" do
      let :params do
        { :apache_version => '2.2' }
      end

      it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^Include "/etc/apache2/conf\.d/\*\.conf"$} }
    end

    context "with Apache version >= 2.4" do
      let :params do
        {
          :apache_version => '2.4',
          :use_optional_includes => true
        }
      end

      it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^IncludeOptional "/etc/apache2/conf\.d/\*\.conf"$} }
    end

    context "when specifying slash encoding behaviour" do
      let :params do
        { :allow_encoded_slashes => 'nodecode' }
      end

      it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^AllowEncodedSlashes nodecode$} }
    end

    context "when specifying default character set" do
      let :params do
        { :default_charset => 'none' }
      end

      it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^AddDefaultCharset none$} }
    end

    # Assert that both load files and conf files are placed and symlinked for these mods
    [
      'alias',
      'autoindex',
      'dav_fs',
      'deflate',
      'dir',
      'mime',
      'negotiation',
      'setenvif',
    ].each do |modname|
      it { is_expected.to contain_file("#{modname}.load").with(
        'path'   => "/etc/apache2/mods-available/#{modname}.load",
        'ensure' => 'file'
      ) }
      it { is_expected.to contain_file("#{modname}.load symlink").with(
        'path'   => "/etc/apache2/mods-enabled/#{modname}.load",
        'ensure' => 'link',
        'target' => "/etc/apache2/mods-available/#{modname}.load"
      ) }
      it { is_expected.to contain_file("#{modname}.conf").with(
        'path'   => "/etc/apache2/mods-available/#{modname}.conf",
        'ensure' => 'file'
      ) }
      it { is_expected.to contain_file("#{modname}.conf symlink").with(
        'path'   => "/etc/apache2/mods-enabled/#{modname}.conf",
        'ensure' => 'link',
        'target' => "/etc/apache2/mods-available/#{modname}.conf"
      ) }
    end

    describe "Check default type" do
      context "with Apache version < 2.4" do
        let :params do
          {
            :apache_version => '2.2',
          }
        end
    
       context "when default_type => 'none'" do
          let :params do
            { :default_type => 'none' }
          end
    
          it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^DefaultType none$} }
        end
        context "when default_type => 'text/plain'" do
          let :params do
            { :default_type => 'text/plain' }
          end
    
          it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^DefaultType text/plain$} }
        end
      end
   
      context "with Apache version >= 2.4" do
        let :params do
          {
            :apache_version => '2.4',
          }
        end
        it { is_expected.to contain_file("/etc/apache2/apache2.conf").without_content %r{^DefaultType [.]*$} }
      end
    end

    describe "Don't create user resource" do
      context "when parameter manage_user is false" do
        let :params do
          { :manage_user => false }
        end

        it { is_expected.not_to contain_user('www-data') }
        it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^User www-data\n} }
      end
    end
    describe "Don't create group resource" do
      context "when parameter manage_group is false" do
        let :params do
          { :manage_group => false }
        end

        it { is_expected.not_to contain_group('www-data') }
        it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^Group www-data\n} }
      end
    end

    describe "Add extra LogFormats" do
      context "When parameter log_formats is a hash" do
        let :params do
          { :log_formats => {
            'vhost_common'   => "%v %h %l %u %t \"%r\" %>s %b",
            'vhost_combined' => "%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""
          } }
        end

        it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^LogFormat "%v %h %l %u %t \"%r\" %>s %b" vhost_common\n} }
        it { is_expected.to contain_file("/etc/apache2/apache2.conf").with_content %r{^LogFormat "%v %h %l %u %t \"%r\" %>s %b \"%\{Referer\}i\" \"%\{User-agent\}i\"" vhost_combined\n} }
      end
    end

    context "on Ubuntu" do
      let :facts do
        super().merge({
          :operatingsystem => 'Ubuntu'
        })
      end

      context "13.10" do
        let :facts do
          super().merge({
            :lsbdistrelease         => '13.10',
            :operatingsystemrelease => '13.10'
          })
        end
        it { is_expected.to contain_class('apache').with_apache_version('2.4') }
      end
      context "12.04" do
        let :facts do
          super().merge({
            :lsbdistrelease         => '12.04',
            :operatingsystemrelease => '12.04'
          })
        end
        it { is_expected.to contain_class('apache').with_apache_version('2.2') }
      end
      context "13.04" do
        let :facts do
          super().merge({
            :lsbdistrelease         => '13.04',
            :operatingsystemrelease => '13.04'
          })
        end
        it { is_expected.to contain_class('apache').with_apache_version('2.2') }
      end
    end
  end
  context "on a RedHat 5 OS" do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '5',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_package("httpd").with(
      'notify' => 'Class[Apache::Service]',
      'ensure' => 'installed'
      )
    }
    it { is_expected.to contain_user("apache") }
    it { is_expected.to contain_group("apache") }
    it { is_expected.to contain_class("apache::service") }
    it { is_expected.to contain_file("/var/www/html").with(
      'ensure'  => 'directory'
      )
    }
    it { is_expected.to contain_file("/etc/httpd/conf.d").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
      )
    }
    it { is_expected.to contain_concat("/etc/httpd/conf/ports.conf").with(
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'notify'  => 'Class[Apache::Service]'
      )
    }
    describe "Alternate confd/mod/vhosts directory" do
      let :params do
        {
          :vhost_dir => '/etc/httpd/site.d',
          :confd_dir => '/etc/httpd/conf.d',
          :mod_dir   => '/etc/httpd/mod.d',
        }
      end

      ['mod.d','site.d','conf.d'].each do |dir|
        it { is_expected.to contain_file("/etc/httpd/#{dir}").with(
          'ensure'  => 'directory',
          'recurse' => 'true',
          'purge'   => 'true',
          'notify'  => 'Class[Apache::Service]',
          'require' => 'Package[httpd]'
        ) }
      end

      # Assert that load files are placed for these mods, but no conf file.
      [
        'auth_basic',
        'authn_file',
        'authz_default',
        'authz_groupfile',
        'authz_host',
        'authz_user',
        'dav',
        'env',
      ].each do |modname|
        it { is_expected.to contain_file("#{modname}.load").with_path(
          "/etc/httpd/mod.d/#{modname}.load"
        ) }
        it { is_expected.not_to contain_file("#{modname}.conf").with_path(
          "/etc/httpd/mod.d/#{modname}.conf"
        ) }
      end

      # Assert that both load files and conf files are placed for these mods
      [
        'alias',
        'autoindex',
        'dav_fs',
        'deflate',
        'dir',
        'mime',
        'negotiation',
        'setenvif',
      ].each do |modname|
        it { is_expected.to contain_file("#{modname}.load").with_path(
          "/etc/httpd/mod.d/#{modname}.load"
        ) }
        it { is_expected.to contain_file("#{modname}.conf").with_path(
          "/etc/httpd/mod.d/#{modname}.conf"
        ) }
      end

      context "with Apache version < 2.4" do
        let :params do
          { :apache_version => '2.2' }
        end

        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^Include "/etc/httpd/conf\.d/\*\.conf"$} }
      end

      context "with Apache version >= 2.4" do
        let :params do
          {
            :apache_version => '2.4',
            :use_optional_includes => true
          }
        end

        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^IncludeOptional "/etc/httpd/conf\.d/\*\.conf"$} }
      end

      context "when specifying slash encoding behaviour" do
        let :params do
          { :allow_encoded_slashes => 'nodecode' }
        end

        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^AllowEncodedSlashes nodecode$} }
      end

      context "when specifying default character set" do
        let :params do
          { :default_charset => 'none' }
        end

        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^AddDefaultCharset none$} }
      end

      context "with Apache version < 2.4" do
        let :params do
          {
            :apache_version => '2.2',
          }
        end

       context "when default_type => 'none'" do
          let :params do
            { :default_type => 'none' }
          end

          it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^DefaultType none$} }
        end
        context "when default_type => 'text/plain'" do
          let :params do
            { :default_type => 'text/plain' }
          end

          it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^DefaultType text/plain$} }
        end
      end

      context "with Apache version >= 2.4" do
        let :params do
          {
            :apache_version => '2.4',
          }
        end
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").without_content %r{^DefaultType [.]*$} }
      end

      it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^Include "/etc/httpd/site\.d/\*"$} }
      it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^Include "/etc/httpd/mod\.d/\*\.conf"$} }
      it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^Include "/etc/httpd/mod\.d/\*\.load"$} }
    end

    describe "Alternate conf directory" do
      let :params do
        { :conf_dir => '/opt/rh/root/etc/httpd/conf' }
      end

      it { is_expected.to contain_file("/opt/rh/root/etc/httpd/conf/httpd.conf").with(
        'ensure'  => 'file',
        'notify'  => 'Class[Apache::Service]',
        'require' => 'Package[httpd]'
      ) }
    end

    describe "Alternate conf.d directory" do
      let :params do
        { :confd_dir => '/etc/httpd/special_conf.d' }
      end

      it { is_expected.to contain_file("/etc/httpd/special_conf.d").with(
        'ensure'  => 'directory',
        'recurse' => 'true',
        'purge'   => 'true',
        'notify'  => 'Class[Apache::Service]',
        'require' => 'Package[httpd]'
      ) }
    end

    describe "Alternate mpm_modules" do
      context "when declaring mpm_module is false" do
        let :params do
          { :mpm_module => false }
        end
        it 'should not declare mpm modules' do
          is_expected.not_to contain_class('apache::mod::event')
          is_expected.not_to contain_class('apache::mod::itk')
          is_expected.not_to contain_class('apache::mod::peruser')
          is_expected.not_to contain_class('apache::mod::prefork')
          is_expected.not_to contain_class('apache::mod::worker')
        end
      end
      context "when declaring mpm_module => prefork" do
        let :params do
          { :mpm_module => 'prefork' }
        end
        it { is_expected.to contain_class('apache::mod::prefork') }
        it { is_expected.not_to contain_class('apache::mod::event') }
        it { is_expected.not_to contain_class('apache::mod::itk') }
        it { is_expected.not_to contain_class('apache::mod::peruser') }
        it { is_expected.not_to contain_class('apache::mod::worker') }
      end
      context "when declaring mpm_module => worker" do
        let :params do
          { :mpm_module => 'worker' }
        end
        it { is_expected.to contain_class('apache::mod::worker') }
        it { is_expected.not_to contain_class('apache::mod::event') }
        it { is_expected.not_to contain_class('apache::mod::itk') }
        it { is_expected.not_to contain_class('apache::mod::peruser') }
        it { is_expected.not_to contain_class('apache::mod::prefork') }
      end
      context "when declaring mpm_module => breakme" do
        let :params do
          { :mpm_module => 'breakme' }
        end
        it { expect { subject }.to raise_error Puppet::Error, /does not match/ }
      end
    end

    describe "different templates for httpd.conf" do
      context "with default" do
        let :params do
          { :conf_template => 'apache/httpd.conf.erb' }
        end
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^# Security\n} }
      end
      context "with non-default" do
        let :params do
          { :conf_template => 'site_apache/fake.conf.erb' }
        end
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^Fake template for rspec.$} }
      end
    end

    describe "default mods" do
      context "without" do
        let :params do
          { :default_mods => false }
        end

        it { is_expected.to contain_apache__mod('authz_host') }
        it { is_expected.not_to contain_apache__mod('env') }
      end
      context "custom" do
        let :params do
          { :default_mods => [
            'info',
            'alias',
            'mime',
            'env',
            'setenv',
            'expires',
          ]}
        end

        it { is_expected.to contain_apache__mod('authz_host') }
        it { is_expected.to contain_apache__mod('env') }
        it { is_expected.to contain_class('apache::mod::info') }
        it { is_expected.to contain_class('apache::mod::mime') }
      end
    end
    describe "Don't create user resource" do
      context "when parameter manage_user is false" do
        let :params do
          { :manage_user => false }
        end

        it { is_expected.not_to contain_user('apache') }
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^User apache\n} }
      end
    end
    describe "Don't create group resource" do
      context "when parameter manage_group is false" do
        let :params do
          { :manage_group => false }
        end

        it { is_expected.not_to contain_group('apache') }
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^Group apache\n} }

      end
    end
    describe "sendfile" do
      context "with invalid value" do
        let :params do
          { :sendfile => 'foo' }
        end
        it "should fail" do
          expect do
            subject
          end.to raise_error(Puppet::Error, /"foo" does not match/)
        end
      end
      context "On" do
        let :params do
          { :sendfile => 'On' }
        end
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^EnableSendfile On\n} }
      end
      context "Off" do
        let :params do
          { :sendfile => 'Off' }
        end
        it { is_expected.to contain_file("/etc/httpd/conf/httpd.conf").with_content %r{^EnableSendfile Off\n} }
      end
    end
    context "on Fedora" do
      let :facts do
        super().merge({
          :operatingsystem => 'Fedora'
        })
      end

      context "21" do
        let :facts do
          super().merge({
            :lsbdistrelease         => '21',
            :operatingsystemrelease => '21'
          })
        end
        it { is_expected.to contain_class('apache').with_apache_version('2.4') }
      end
      context "Rawhide" do
        let :facts do
          super().merge({
            :lsbdistrelease         => 'Rawhide',
            :operatingsystemrelease => 'Rawhide'
          })
        end
        it { is_expected.to contain_class('apache').with_apache_version('2.4') }
      end
      # kinda obsolete
      context "17" do
        let :facts do
          super().merge({
            :lsbdistrelease         => '17',
            :operatingsystemrelease => '17'
          })
        end
        it { is_expected.to contain_class('apache').with_apache_version('2.2') }
      end
    end
  end
  context "on a FreeBSD OS" do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'FreeBSD',
        :osfamily               => 'FreeBSD',
        :operatingsystem        => 'FreeBSD',
        :operatingsystemrelease => '10',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_class("apache::package").with({'ensure' => 'present'}) }
    it { is_expected.to contain_user("www") }
    it { is_expected.to contain_group("www") }
    it { is_expected.to contain_class("apache::service") }
    it { is_expected.to contain_file("/usr/local/www/apache24/data").with(
      'ensure'  => 'directory'
      )
    }
    it { is_expected.to contain_file("/usr/local/etc/apache24/Vhosts").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
    ) }
    it { is_expected.to contain_file("/usr/local/etc/apache24/Modules").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
    ) }
    it { is_expected.to contain_concat("/usr/local/etc/apache24/ports.conf").with(
      'owner'   => 'root',
      'group'   => 'wheel',
      'mode'    => '0644',
      'notify'  => 'Class[Apache::Service]'
    ) }
    # Assert that load files are placed for these mods, but no conf file.
    [
      'auth_basic',
      'authn_file',
      'authz_groupfile',
      'authz_host',
      'authz_user',
      'dav',
      'env'
    ].each do |modname|
      it { is_expected.to contain_file("#{modname}.load").with(
        'path'   => "/usr/local/etc/apache24/Modules/#{modname}.load",
        'ensure' => 'file'
      ) }
      it { is_expected.not_to contain_file("#{modname}.conf") }
    end

    # Assert that both load files and conf files are placed for these mods
    [
      'alias',
      'autoindex',
      'dav_fs',
      'deflate',
      'dir',
      'mime',
      'negotiation',
      'setenvif',
    ].each do |modname|
      it { is_expected.to contain_file("#{modname}.load").with(
        'path'   => "/usr/local/etc/apache24/Modules/#{modname}.load",
        'ensure' => 'file'
      ) }
      it { is_expected.to contain_file("#{modname}.conf").with(
        'path'   => "/usr/local/etc/apache24/Modules/#{modname}.conf",
        'ensure' => 'file'
      ) }
    end
  end
  context "on a Gentoo OS" do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'Gentoo',
        :operatingsystem        => 'Gentoo',
        :operatingsystemrelease => '3.16.1-gentoo',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
        :is_pe                  => false,
      }
    end
    it { is_expected.to contain_class("apache::params") }
    it { is_expected.to contain_user("apache") }
    it { is_expected.to contain_group("apache") }
    it { is_expected.to contain_class("apache::service") }
    it { is_expected.to contain_file("/var/www/localhost/htdocs").with(
      'ensure'  => 'directory'
      )
    }
    it { is_expected.to contain_file("/etc/apache2/vhosts.d").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
    ) }
    it { is_expected.to contain_file("/etc/apache2/modules.d").with(
      'ensure'  => 'directory',
      'recurse' => 'true',
      'purge'   => 'true',
      'notify'  => 'Class[Apache::Service]',
      'require' => 'Package[httpd]'
    ) }
    it { is_expected.to contain_concat("/etc/apache2/ports.conf").with(
      'owner'   => 'root',
      'group'   => 'wheel',
      'mode'    => '0644',
      'notify'  => 'Class[Apache::Service]'
    ) }
  end
  context 'on all OSes' do
    let :facts do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :osfamily               => 'RedHat',
        :operatingsystem        => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context 'with a custom apache_name parameter' do
      let :params do {
        :apache_name => 'httpd24-httpd'
      }
      end
      it { is_expected.to contain_package("httpd").with(
        'notify' => 'Class[Apache::Service]',
        'ensure' => 'installed',
        'name'   => 'httpd24-httpd'
        )
      }
    end
    context 'default vhost defaults' do
      it { is_expected.to contain_apache__vhost('default').with_ensure('present') }
      it { is_expected.to contain_apache__vhost('default-ssl').with_ensure('absent') }
    end
    context 'without default non-ssl vhost' do
      let :params do {
        :default_vhost  => false
      }
      end
      it { is_expected.to contain_apache__vhost('default').with_ensure('absent') }
      it { is_expected.not_to contain_file('/var/www/html') }
    end
    context 'with default ssl vhost' do
      let :params do {
          :default_ssl_vhost  => true
        }
      end
      it { is_expected.to contain_apache__vhost('default-ssl').with_ensure('present') }
      it { is_expected.to contain_file('/var/www/html') }
    end
  end
  context 'with unsupported osfamily' do
    let :facts do
      { :osfamily        => 'Darwin',
        :operatingsystemrelease => '13.1.0',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end

    it do
      expect {
       should compile
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    end
  end
end
