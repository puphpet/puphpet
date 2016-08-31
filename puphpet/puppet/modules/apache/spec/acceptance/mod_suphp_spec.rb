require 'spec_helper_acceptance'

describe 'apache::mod::suphp class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  case fact('operatingsystem')
    when 'Ubuntu'
      context "default suphp config" do
        it 'succeeds in puppeting suphp' do
          pp = <<-EOS
class { 'apache':
  mpm_module => 'prefork',
}
host { 'suphp.example.com': ip => '127.0.0.1', }
apache::vhost { 'suphp.example.com':
  port    => '80',
  docroot => '/var/www/suphp',
}
file { '/var/www/suphp/index.php':
  ensure  => file,
  owner   => 'daemon',
  group   => 'daemon',
  content => "<?php echo get_current_user(); ?>\\n",
  require => File['/var/www/suphp'],
  before  => Class['apache::mod::php'],
}
class { 'apache::mod::php': }
class { 'apache::mod::suphp': }
          EOS
          apply_manifest(pp, :catch_failures => true)
        end

        describe service('apache2') do
          it { is_expected.to be_enabled }
          it { is_expected.to be_running }
        end

        it 'should answer to suphp.example.com' do
          timeout = 0
          loop do
            r = shell('curl suphp.example.com:80')
            timeout += 1
            break if r.stdout =~ /^daemon$/
            if timeout > 40
              expect(timeout < 40).to be true
              break
            end
            sleep(1)
          end
          shell("/usr/bin/curl suphp.example.com:80") do |r|
            expect(r.stdout).to match(/^daemon$/)
            expect(r.exit_code).to eq(0)
          end
        end
      end
  end
end
