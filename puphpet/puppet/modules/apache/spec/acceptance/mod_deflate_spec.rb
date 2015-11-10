require 'spec_helper_acceptance'

describe 'apache::mod::deflate class' do
  case fact('osfamily')
  when 'Debian'
    mod_dir      = '/etc/apache2/mods-available'
    service_name = 'apache2'
  when 'RedHat'
    mod_dir      = '/etc/httpd/conf.d'
    service_name = 'httpd'
  when 'FreeBSD'
    mod_dir      = '/usr/local/etc/apache24/Modules'
    service_name = 'apache24'
  when 'Gentoo'
    mod_dir      = '/etc/apache2/modules.d'
    service_name = 'apache2'
  end

  context "default deflate config" do
    it 'succeeds in puppeting deflate' do
      pp= <<-EOS
        class { 'apache': }
        include apache::mod::deflate
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file("#{mod_dir}/deflate.conf") do
      it { is_expected.to contain "AddOutputFilterByType DEFLATE text/html text/plain text/xml" }
      it { is_expected.to contain "AddOutputFilterByType DEFLATE text/css" }
      it { is_expected.to contain "AddOutputFilterByType DEFLATE application/x-javascript application/javascript application/ecmascript" }
      it { is_expected.to contain "AddOutputFilterByType DEFLATE application/rss+xml" }
      it { is_expected.to contain "DeflateFilterNote Input instream" }
      it { is_expected.to contain "DeflateFilterNote Output outstream" }
      it { is_expected.to contain "DeflateFilterNote Ratio ratio" }
    end
  end
end
