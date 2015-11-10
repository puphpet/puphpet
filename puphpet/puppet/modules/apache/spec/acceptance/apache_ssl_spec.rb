require 'spec_helper_acceptance'
require_relative './version.rb'

case fact('osfamily')
when 'RedHat'
  vhostd = '/etc/httpd/conf.d'
when 'Debian'
  vhostd = '/etc/apache2/sites-available'
end

describe 'apache ssl', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'ssl parameters' do
    it 'runs without error' do
      pp = <<-EOS
        class { 'apache':
          service_ensure        => stopped,
          default_ssl_vhost     => true,
          default_ssl_cert      => '/tmp/ssl_cert',
          default_ssl_key       => '/tmp/ssl_key',
          default_ssl_chain     => '/tmp/ssl_chain',
          default_ssl_ca        => '/tmp/ssl_ca',
          default_ssl_crl_path  => '/tmp/ssl_crl_path',
          default_ssl_crl       => '/tmp/ssl_crl',
          default_ssl_crl_check => 'chain',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{vhostd}/15-default-ssl.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'SSLCertificateFile      "/tmp/ssl_cert"' }
      it { is_expected.to contain 'SSLCertificateKeyFile   "/tmp/ssl_key"' }
      it { is_expected.to contain 'SSLCertificateChainFile "/tmp/ssl_chain"' }
      it { is_expected.to contain 'SSLCACertificateFile    "/tmp/ssl_ca"' }
      it { is_expected.to contain 'SSLCARevocationPath     "/tmp/ssl_crl_path"' }
      it { is_expected.to contain 'SSLCARevocationFile     "/tmp/ssl_crl"' }
      if $apache_version == '2.4'
        it { is_expected.to contain 'SSLCARevocationCheck    "chain"' }
      else
        it { is_expected.not_to contain 'SSLCARevocationCheck' }
      end
    end
  end

  describe 'vhost ssl parameters' do
    it 'runs without error' do
      pp = <<-EOS
        class { 'apache':
          service_ensure       => stopped,
        }

        apache::vhost { 'test_ssl':
          docroot              => '/tmp/test',
          ssl                  => true,
          ssl_cert             => '/tmp/ssl_cert',
          ssl_key              => '/tmp/ssl_key',
          ssl_chain            => '/tmp/ssl_chain',
          ssl_ca               => '/tmp/ssl_ca',
          ssl_crl_path         => '/tmp/ssl_crl_path',
          ssl_crl              => '/tmp/ssl_crl',
          ssl_crl_check        => 'chain',
          ssl_certs_dir        => '/tmp',
          ssl_protocol         => 'test',
          ssl_cipher           => 'test',
          ssl_honorcipherorder => 'test',
          ssl_verify_client    => 'test',
          ssl_verify_depth     => 'test',
          ssl_options          => ['test', 'test1'],
          ssl_proxyengine      => true,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{vhostd}/25-test_ssl.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'SSLCertificateFile      "/tmp/ssl_cert"' }
      it { is_expected.to contain 'SSLCertificateKeyFile   "/tmp/ssl_key"' }
      it { is_expected.to contain 'SSLCertificateChainFile "/tmp/ssl_chain"' }
      it { is_expected.to contain 'SSLCACertificateFile    "/tmp/ssl_ca"' }
      it { is_expected.to contain 'SSLCARevocationPath     "/tmp/ssl_crl_path"' }
      it { is_expected.to contain 'SSLCARevocationFile     "/tmp/ssl_crl"' }
      it { is_expected.to contain 'SSLProxyEngine On' }
      it { is_expected.to contain 'SSLProtocol             test' }
      it { is_expected.to contain 'SSLCipherSuite          test' }
      it { is_expected.to contain 'SSLHonorCipherOrder     test' }
      it { is_expected.to contain 'SSLVerifyClient         test' }
      it { is_expected.to contain 'SSLVerifyDepth          test' }
      it { is_expected.to contain 'SSLOptions test test1' }
      if $apache_version == '2.4'
        it { is_expected.to contain 'SSLCARevocationCheck    "chain"' }
      else
        it { is_expected.not_to contain 'SSLCARevocationCheck' }
      end
    end
  end

end
