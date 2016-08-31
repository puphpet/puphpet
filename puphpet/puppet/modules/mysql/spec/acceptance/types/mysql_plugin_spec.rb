require 'spec_helper_acceptance'

# Different operating systems (and therefore different versions/forks
# of mysql) have varying levels of support for plugins and have
# different plugins available. Choose a plugin that works or don't try
# to test plugins if not available.
if fact('osfamily') =~ /RedHat/
  if fact('operatingsystemrelease') =~ /^5\./
    plugin = nil # Plugins not supported on mysql on RHEL 5
  elsif fact('operatingsystemrelease') =~ /^6\./
    plugin     = 'example'
    plugin_lib = 'ha_example.so'
  elsif fact('operatingsystemrelease') =~ /^7\./
    plugin     = 'pam'
    plugin_lib = 'auth_pam.so'
  end
elsif fact('osfamily') =~ /Debian/
  if fact('operatingsystem') =~ /Debian/
    if fact('operatingsystemrelease') =~ /^6\./
      # Only available plugin is innodb which is already loaded and not unload- or reload-able
      plugin = nil
    elsif fact('operatingsystemrelease') =~ /^7\./
      plugin     = 'example'
      plugin_lib = 'ha_example.so'
    end
  elsif fact('operatingsystem') =~ /Ubuntu/
    if fact('operatingsystemrelease') =~ /^10\.04/
      # Only available plugin is innodb which is already loaded and not unload- or reload-able
      plugin = nil
    else
      plugin     = 'example'
      plugin_lib = 'ha_example.so'
    end
  end
elsif fact('osfamily') =~ /Suse/
  plugin = nil # Plugin library path is broken on Suse http://lists.opensuse.org/opensuse-bugs/2013-08/msg01123.html
end

describe 'mysql_plugin' do
  if plugin # if plugins are supported
    describe 'setup' do
      it 'should work with no errors' do
        pp = <<-EOS
          class { 'mysql::server': }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end
    end

    describe 'load plugin' do
      it 'should work without errors' do
        pp = <<-EOS
          mysql_plugin { #{plugin}:
            ensure => present,
            soname => '#{plugin_lib}',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      it 'should find the plugin' do
        shell("mysql -NBe \"select plugin_name from information_schema.plugins where plugin_name='#{plugin}'\"") do |r|
          expect(r.stdout).to match(/^#{plugin}$/i)
          expect(r.stderr).to be_empty
        end
      end
    end
  end

end
