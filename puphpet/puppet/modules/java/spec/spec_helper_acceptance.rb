require 'beaker-rspec'

UNSUPPORTED_PLATFORMS = [ "Darwin", "windows" ]

unless ENV["RS_PROVISION"] == "no" or ENV["BEAKER_provision"] == "no"
  # This will install the latest available package on el and deb based
  # systems fail on windows and osx, and install via gem on other *nixes
  foss_opts = { :default_action => 'gem_install' }

  if default.is_pe?; then install_pe; else install_puppet( foss_opts ); end

  hosts.each do |host|
    if host["platform"] =~ /solaris/
      on host, "echo 'export PATH=/opt/puppet/bin:/var/ruby/1.8/gem_home/bin:${PATH}' >> ~/.bashrc"
    end
    unless host.is_pe?
      on host, "/bin/mkdir -p #{host["puppetpath"]}"
      on host, "/bin/echo '' > #{host["hieraconf"]}"
    end
    on host, "mkdir -p #{host["distmoduledir"]}"
    if host['platform'] =~ /sles-1/i ||  host['platform'] =~ /solaris-1/i
      get_stdlib = <<-stdlib
      package{'wget':}
      exec{'download':
        command => "wget -P /root/ https://forgeapi.puppetlabs.com/v3/files/puppetlabs-stdlib-4.3.2.tar.gz --no-check-certificate",
        path => ['/opt/csw/bin/','/usr/bin/']
      }
      stdlib
      apply_manifest_on(host, get_stdlib)
      # have to use force otherwise it checks ssl cert even though it is a local file
      on host, puppet('module install /root/puppetlabs-stdlib-4.3.2.tar.gz --force')
    else
      on host, puppet("module install puppetlabs-stdlib")
      # For test support
      on host, puppet("module install puppetlabs-apt")
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => "java")
    end
  end
end
