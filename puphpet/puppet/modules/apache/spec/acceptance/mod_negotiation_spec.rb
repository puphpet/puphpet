require 'spec_helper_acceptance'

describe 'apache::mod::negotiation class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  case fact('osfamily')
  when 'Debian'
    vhost_dir    = '/etc/apache2/sites-enabled'
    mod_dir      = '/etc/apache2/mods-available'
    service_name = 'apache2'
  when 'RedHat'
    vhost_dir    = '/etc/httpd/conf.d'
    mod_dir      = '/etc/httpd/conf.d'
    service_name = 'httpd'
  when 'FreeBSD'
    vhost_dir    = '/usr/local/etc/apache24/Vhosts'
    mod_dir      = '/usr/local/etc/apache24/Modules'
    service_name = 'apache24'
  when 'Gentoo'
    vhost_dir    = '/etc/apache2/vhosts.d'
    mod_dir      = '/etc/apache2/modules.d'
    service_name = 'apache2'
  end

  context "default negotiation config" do
    it 'succeeds in puppeting negotiation' do
      pp= <<-EOS
        class { '::apache': default_mods => false }
        class { '::apache::mod::negotiation': }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{mod_dir}/negotiation.conf") do
      it { should contain "LanguagePriority en ca cs da de el eo es et fr he hr it ja ko ltz nl nn no pl pt pt-BR ru sv zh-CN zh-TW
ForceLanguagePriority Prefer Fallback" }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context "with alternative force_language_priority" do
    it 'succeeds in puppeting negotiation' do
      pp= <<-EOS
        class { '::apache': default_mods => false }
        class { '::apache::mod::negotiation':
          force_language_priority => 'Prefer',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{mod_dir}/negotiation.conf") do
      it { should contain "ForceLanguagePriority Prefer" }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  context "with alternative language_priority" do
    it 'succeeds in puppeting negotiation' do
      pp= <<-EOS
        class { '::apache': default_mods => false }
        class { '::apache::mod::negotiation':
          language_priority => [ 'en', 'es' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{mod_dir}/negotiation.conf") do
      it { should contain "LanguagePriority en es" }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
