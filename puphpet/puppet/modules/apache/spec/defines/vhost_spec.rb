require 'spec_helper'

describe 'apache::vhost', :type => :define do
  let :pre_condition do
    'class { "apache": default_vhost => false, default_mods => false, vhost_enable_dir => "/etc/apache2/sites-enabled"}'
  end
  let :title do
    'rspec.example.com'
  end
  let :default_params do
    {
      :docroot => '/rspec/docroot',
      :port    => '84',
    }
  end
  describe 'os-dependent items' do
    context "on RedHat based systems" do
      let :default_facts do
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
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
    end
    context "on Debian based systems" do
      let :default_facts do
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
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_file("25-rspec.example.com.conf").with(
        :ensure => 'present',
        :path   => '/etc/apache2/sites-available/25-rspec.example.com.conf'
      ) }
      it { is_expected.to contain_file("25-rspec.example.com.conf symlink").with(
        :ensure => 'link',
        :path   => '/etc/apache2/sites-enabled/25-rspec.example.com.conf',
        :target => '/etc/apache2/sites-available/25-rspec.example.com.conf'
      ) }
    end
    context "on FreeBSD systems" do
      let :default_facts do
        {
          :osfamily               => 'FreeBSD',
          :operatingsystemrelease => '9',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'FreeBSD',
          :id                     => 'root',
          :kernel                 => 'FreeBSD',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_file("25-rspec.example.com.conf").with(
        :ensure => 'present',
        :path   => '/usr/local/etc/apache24/Vhosts/25-rspec.example.com.conf'
      ) }
    end
    context "on Gentoo systems" do
      let :default_facts do
        {
          :osfamily               => 'Gentoo',
          :operatingsystem        => 'Gentoo',
          :operatingsystemrelease => '3.16.1-gentoo',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_file("25-rspec.example.com.conf").with(
        :ensure => 'present',
        :path   => '/etc/apache2/vhosts.d/25-rspec.example.com.conf'
      ) }
    end
  end
  describe 'os-independent items' do
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
    describe 'basic assumptions' do
      let :params do default_params end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__listen(params[:port]) }
      it { is_expected.to contain_apache__namevirtualhost("*:#{params[:port]}") }
    end
    context 'set everything!' do
      let :params do
        {
          'docroot'                     => '/var/www/foo',
          'manage_docroot'              => false,
          'virtual_docroot'             => true,
          'port'                        => '8080',
          'ip'                          => '127.0.0.1',
          'ip_based'                    => true,
          'add_listen'                  => false,
          'docroot_owner'               => 'user',
          'docroot_group'               => 'wheel',
          'docroot_mode'                => '0664',
          'serveradmin'                 => 'foo@localhost',
          'ssl'                         => true,
          'ssl_cert'                    => '/ssl/cert',
          'ssl_key'                     => '/ssl/key',
          'ssl_chain'                   => '/ssl/chain',
          'ssl_crl_path'                => '/ssl/crl',
          'ssl_crl'                     => 'foo.crl',
          'ssl_certs_dir'               => '/ssl/certs',
          'ssl_protocol'                => 'SSLv2',
          'ssl_cipher'                  => 'HIGH',
          'ssl_honorcipherorder'        => 'Off',
          'ssl_verify_client'           => 'optional',
          'ssl_verify_depth'            => '3',
          'ssl_options'                 => '+ExportCertData',
          'ssl_proxyengine'             => true,
          'priority'                    => '30',
          'default_vhost'               => true,
          'servername'                  => 'example.com',
          'serveraliases'               => ['test-example.com'],
          'options'                     => ['MultiView'],
          'override'                    => ['All'],
          'directoryindex'              => 'index.html',
          'vhost_name'                  => 'test',
          'logroot'                     => '/var/www/logs',
          'logroot_ensure'              => 'directory',
          'logroot_mode'                => '0600',
          'log_level'                   => 'crit',
          'access_log'                  => false,
          'access_log_file'             => 'httpd_access_log',
          'access_log_pipe'             => '',
          'access_log_syslog'           => true,
          'access_log_format'           => '%h %l %u %t \"%r\" %>s %b',
          'access_log_env_var'          => '',
          'aliases'                     => '/image',
          'directories'                 => [
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  => [ 'valid-user', 'all denied', ],
            },
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  => 'all granted',
            },
          ],
          'error_log'                   => false,
          'error_log_file'              => 'httpd_error_log',
          'error_log_pipe'              => '',
          'error_log_syslog'            => true,
          'error_documents'             => 'true',
          'fallbackresource'            => '/index.php',
          'scriptalias'                 => '/usr/lib/cgi-bin',
          'scriptaliases'               => [
            {
              'alias' => '/myscript',
              'path'  => '/usr/share/myscript',
            },
            {
              'aliasmatch' => '^/foo(.*)',
              'path'       => '/usr/share/fooscripts$1',
            },
          ],
          'proxy_dest'                  => '/',
          'proxy_pass'                  => [
            {
              'path'     => '/a',
              'url'      => 'http://backend-a/',
              'keywords' => ['noquery', 'interpolate'],
              'params'   => {
                      'retry'   => '0',
                      'timeout' => '5'
              },
              'setenv'   => ['proxy-nokeepalive 1','force-proxy-request-1.0 1'],
            }
          ],
          'proxy_pass_match'            => [
            {
              'path'     => '/a',
              'url'      => 'http://backend-a/',
              'keywords' => ['noquery', 'interpolate'],
              'params'   => {
                      'retry'   => '0',
                      'timeout' => '5'
              },
              'setenv'   => ['proxy-nokeepalive 1','force-proxy-request-1.0 1'],
            }
          ],
          'suphp_addhandler'            => 'foo',
          'suphp_engine'                => 'on',
          'suphp_configpath'            => '/var/www/html',
          'php_admin_flags'             => ['foo', 'bar'],
          'php_admin_values'            => ['true', 'false'],
          'no_proxy_uris'               => '/foo',
          'no_proxy_uris_match'         => '/foomatch',
          'proxy_preserve_host'         => true,
          'proxy_error_override'        => true,
          'redirect_source'             => '/bar',
          'redirect_dest'               => '/',
          'redirect_status'             => 'temp',
          'redirectmatch_status'        => ['404'],
          'redirectmatch_regexp'        => ['\.git$'],
          'redirectmatch_dest'          => ['http://www.example.com'],
          'rack_base_uris'              => ['/rackapp1'],
          'headers'                     => 'Set X-Robots-Tag "noindex, noarchive, nosnippet"',
          'request_headers'             => ['append MirrorID "mirror 12"'],
          'rewrites'                    => [
            {
              'rewrite_rule' => ['^index\.html$ welcome.html']
            }
          ],
          'rewrite_base'                => '/',
          'rewrite_rule'                => '^index\.html$ welcome.html',
          'rewrite_cond'                => '%{HTTP_USER_AGENT} ^MSIE',
          'setenv'                      => ['FOO=/bin/true'],
          'setenvif'                    => 'Request_URI "\.gif$" object_is_image=gif',
          'block'                       => 'scm',
          'wsgi_application_group'      => '%{GLOBAL}',
          'wsgi_daemon_process'         => 'wsgi',
          'wsgi_daemon_process_options' => {
            'processes'    => '2',
            'threads'      => '15',
            'display-name' => '%{GROUP}',
          },
          'wsgi_import_script'          => '/var/www/demo.wsgi',
          'wsgi_import_script_options'  => {
            'process-group'     => 'wsgi',
            'application-group' => '%{GLOBAL}'
          },
          'wsgi_process_group'          => 'wsgi',
          'wsgi_script_aliases'         => {
            '/' => '/var/www/demo.wsgi'
          },
          'wsgi_pass_authorization'     => 'On',
          'custom_fragment'             => '#custom string',
          'itk'                         => {
            'user'  => 'someuser',
            'group' => 'somegroup'
          },
          'wsgi_chunked_request'        => 'On',
          'action'                      => 'foo',
          'fastcgi_server'              => 'localhost',
          'fastcgi_socket'              => '/tmp/fastcgi.socket',
          'fastcgi_dir'                 => '/tmp',
          'additional_includes'         => '/custom/path/includes',
          'apache_version'              => '2.4',
          'suexec_user_group'           => 'root root',
          'allow_encoded_slashes'       => 'nodecode',
          'passenger_app_root'          => '/usr/share/myapp',
          'passenger_app_env'           => 'test',
          'passenger_ruby'              => '/usr/bin/ruby1.9.1',
          'passenger_min_instances'     => '1',
          'passenger_start_timeout'     => '600',
          'passenger_pre_start'         => 'http://localhost/myapp',
          'add_default_charset'         => 'UTF-8',
        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to_not contain_file('/var/www/foo') }
      it { is_expected.to contain_class('apache::mod::ssl') }
      it { is_expected.to contain_file('ssl.conf').with(
        :content => /^\s+SSLHonorCipherOrder On$/ ) }
      it { is_expected.to contain_file('ssl.conf').with(
        :content => /^\s+SSLPassPhraseDialog builtin$/ ) }
      it { is_expected.to contain_file('ssl.conf').with(
        :content => /^\s+SSLSessionCacheTimeout 300$/ ) }
      it { is_expected.to contain_class('apache::mod::mime') }
      it { is_expected.to contain_class('apache::mod::vhost_alias') }
      it { is_expected.to contain_class('apache::mod::wsgi') }
      it { is_expected.to contain_class('apache::mod::suexec') }
      it { is_expected.to contain_class('apache::mod::passenger') }
      it { is_expected.to contain_file('/var/www/logs').with({
        'ensure' => 'directory',
        'mode'   => '0600',
      })
      }
      it { is_expected.to contain_class('apache::mod::rewrite') }
      it { is_expected.to contain_class('apache::mod::alias') }
      it { is_expected.to contain_class('apache::mod::proxy') }
      it { is_expected.to contain_class('apache::mod::proxy_http') }
      it { is_expected.to contain_class('apache::mod::passenger') }
      it { is_expected.to contain_class('apache::mod::passenger') }
      it { is_expected.to contain_class('apache::mod::fastcgi') }
      it { is_expected.to contain_class('apache::mod::headers') }
      it { is_expected.to contain_class('apache::mod::setenvif') }
      it { is_expected.to contain_concat('30-rspec.example.com.conf').with({
        'owner'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[httpd]',
        'notify'  => 'Class[Apache::Service]',
      })
      }
      it { is_expected.to contain_file('30-rspec.example.com.conf symlink').with({
        'ensure' => 'link',
        'path'   => '/etc/apache2/sites-enabled/30-rspec.example.com.conf',
      })
      }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-docroot') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-aliases') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-itk') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-fallbackresource') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require valid-user$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all denied$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all granted$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-additional_includes') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-logging') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-serversignature') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-access_log') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-action') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-block') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-error_document') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /retry=0/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /timeout=5/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /SetEnv force-proxy-request-1.0 1/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /SetEnv proxy-nokeepalive 1/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /noquery interpolate/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-rack') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-redirect') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-rewrite') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-scriptalias') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-serveralias') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-setenv') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-ssl') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-suphp') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-php_admin') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-header') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-requestheader') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-wsgi') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-custom_fragment') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-fastcgi') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-suexec') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-allow_encoded_slashes') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-passenger') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-charsets') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-file_footer') }
    end
    context 'not everything can be set together...' do
      let :params do
        {
          'access_log_pipe' => '/dev/null',
          'error_log_pipe'  => '/dev/null',
          'docroot'         => '/var/www/foo',
          'ensure'          => 'absent',
          'manage_docroot'  => true,
          'logroot'         => '/tmp/logroot',
          'logroot_ensure'  => 'absent',
          'directories'     => [
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'allow'    => [ 'from 127.0.0.1', 'from 127.0.0.2', ],
              'deny'     => [ 'from 127.0.0.3', 'from 127.0.0.4', ],
              'satisfy'  => 'any',
            },
            {
              'path'     => '/var/www/foo',
              'provider' => 'files',
              'allow'    => 'from 127.0.0.5',
              'deny'     => 'from all',
              'order'    => 'deny,allow',
            },
          ],

        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to_not contain_class('apache::mod::ssl') }
      it { is_expected.to_not contain_class('apache::mod::mime') }
      it { is_expected.to_not contain_class('apache::mod::vhost_alias') }
      it { is_expected.to_not contain_class('apache::mod::wsgi') }
      it { is_expected.to_not contain_class('apache::mod::passenger') }
      it { is_expected.to_not contain_class('apache::mod::suexec') }
      it { is_expected.to_not contain_class('apache::mod::rewrite') }
      it { is_expected.to contain_class('apache::mod::alias') }
      it { is_expected.to_not contain_class('apache::mod::proxy') }
      it { is_expected.to_not contain_class('apache::mod::proxy_http') }
      it { is_expected.to_not contain_class('apache::mod::passenger') }
      it { is_expected.to_not contain_class('apache::mod::headers') }
      it { is_expected.to contain_file('/var/www/foo') }
      it { is_expected.to contain_file('/tmp/logroot').with({
        'ensure' => 'absent',
      })
      }
      it { is_expected.to contain_concat('25-rspec.example.com.conf').with({
        'ensure' => 'absent',
      })
      }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-docroot') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-aliases') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-itk') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-fallbackresource') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Allow from 127\.0\.0\.1$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Allow from 127\.0\.0\.2$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Allow from 127\.0\.0\.5$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Deny from 127\.0\.0\.3$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Deny from 127\.0\.0\.4$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Deny from all$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Satisfy any$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Order deny,allow$/ ) }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-additional_includes') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-logging') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-serversignature') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-action') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-block') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-error_document') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-proxy') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-rack') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-redirect') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-rewrite') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-scriptalias') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-serveralias') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-setenv') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-ssl') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-suphp') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-php_admin') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-header') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-requestheader') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-wsgi') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-custom_fragment') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-fastcgi') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-suexec') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-charsets') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-file_footer') }
    end
  end
  describe 'access logs' do
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
    context 'single log file' do
      let(:params) do
        {
          'docroot'         => '/rspec/docroot',
          'access_log_file' => 'my_log_file',
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog.*my_log_file" combined\s*$/
      )}
    end
    context 'single log file with environment' do
      let(:params) do
        {
          'docroot'            => '/rspec/docroot',
          'access_log_file'    => 'my_log_file',
          'access_log_env_var' => 'prod'
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog.*my_log_file" combined\s+env=prod$/
      )}
    end
    context 'multiple log files' do
      let(:params) do
        {
          'docroot'     => '/rspec/docroot',
          'access_logs' => [
            { 'file' => '/tmp/log1', 'env' => 'dev' },
            { 'file' => 'log2' },
            { 'syslog' => 'syslog', 'format' => '%h %l' }
          ],
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog "\/tmp\/log1"\s+combined\s+env=dev$/
      )}
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog "\/var\/log\/httpd\/log2"\s+combined\s*$/
      )}
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog "syslog" "%h %l"\s*$/
      )}
    end
  end # access logs
  describe 'validation' do
    context 'bad ensure' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'ensure'  => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad suphp_engine' do
      let :params do
        {
          'docroot'      => '/rspec/docroot',
          'suphp_engine' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad ip_based' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'ip_based' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad access_log' do
      let :params do
        {
          'docroot'    => '/rspec/docroot',
          'access_log' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad error_log' do
      let :params do
        {
          'docroot'   => '/rspec/docroot',
          'error_log' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad_ssl' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'ssl'     => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad default_vhost' do
      let :params do
        {
          'docroot'       => '/rspec/docroot',
          'default_vhost' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad ssl_proxyengine' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'ssl_proxyengine' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad rewrites' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'rewrites' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad rewrites 2' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'rewrites' => ['bogus'],
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad suexec_user_group' do
      let :params do
        {
          'docroot'           => '/rspec/docroot',
          'suexec_user_group' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad wsgi_script_alias' do
      let :params do
        {
          'docroot'           => '/rspec/docroot',
          'wsgi_script_alias' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad wsgi_daemon_process_options' do
      let :params do
        {
          'docroot'                     => '/rspec/docroot',
          'wsgi_daemon_process_options' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad wsgi_import_script_alias' do
      let :params do
        {
          'docroot'                  => '/rspec/docroot',
          'wsgi_import_script_alias' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad itk' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'itk'     => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad logroot_ensure' do
      let :params do
        {
          'docroot'   => '/rspec/docroot',
          'log_level' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad log_level' do
      let :params do
        {
          'docroot'   => '/rspec/docroot',
          'log_level' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'access_log_file and access_log_pipe' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'access_log_file' => 'bogus',
          'access_log_pipe' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'error_log_file and error_log_pipe' do
      let :params do
        {
          'docroot'        => '/rspec/docroot',
          'error_log_file' => 'bogus',
          'error_log_pipe' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad fallbackresource' do
      let :params do
        {
          'docroot'          => '/rspec/docroot',
          'fallbackresource' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad custom_fragment' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'custom_fragment' => true,
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad access_logs' do
      let :params do
        {
          'docroot'     => '/rspec/docroot',
          'access_logs' => '/var/log/somewhere',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
  end
  describe 'allow/deny/order/satisfy deprecation validation' do
    let :default_facts do
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
    context 'bad allow parameter' do
      let :params do
        {
          'docroot'        => '/var/www/files',
          'apache_version' => '2.4',
          'directories'    => {
            'path'     => '/var/www/files',
            'provider' => 'files',
            'allow'    => 'from 127.0.0.1',
          },
        }
      end
      let :facts do default_facts end
      it do
        expect {
          should contain_concat__fragment('rspec.example.com-directories')
        }.to raise_error(Puppet::Error)
      end
    end
    context 'bad deny parameter' do
      let :params do
        {
          'docroot'        => '/var/www/files',
          'apache_version' => '2.4',
          'directories'    => {
            'path'     => '/var/www/files',
            'provider' => 'files',
            'deny'     => 'from 127.0.0.1',
          },
        }
      end
      let :facts do default_facts end
      it do
        expect {
          should contain_concat__fragment('rspec.example.com-directories')
        }.to raise_error(Puppet::Error)
      end
    end
    context 'bad satisfy parameter' do
      let :params do
        {
          'docroot'        => '/var/www/files',
          'apache_version' => '2.4',
          'directories'    => {
            'path'     => '/var/www/files',
            'provider' => 'files',
            'satisfy'  => 'any',
          },
        }
      end
      let :facts do default_facts end
      it do
        expect {
          should contain_concat__fragment('rspec.example.com-directories')
        }.to raise_error(Puppet::Error)
      end
    end
    context 'bad order parameter' do
      let :params do
        {
          'docroot'        => '/var/www/files',
          'apache_version' => '2.4',
          'directories'    => {
            'path'     => '/var/www/files',
            'provider' => 'files',
            'order'    => 'deny,allow',
          },
        }
      end
      let :facts do default_facts end
      it do
        expect {
          should contain_concat__fragment('rspec.example.com-directories')
        }.to raise_error(Puppet::Error)
      end
    end
  end
end
