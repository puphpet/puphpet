apt_package_updates = nil
Facter.add("apt_has_updates") do
  confine :osfamily => 'Debian'
  if File.executable?("/usr/lib/update-notifier/apt-check")
    apt_check_result = Facter::Util::Resolution.exec('/usr/lib/update-notifier/apt-check 2>&1')
    if not apt_check_result.nil? and apt_check_result =~ /^\d+;\d+$/
      apt_package_updates = apt_check_result.split(';')
    end
  end

  setcode do
    if not apt_package_updates.nil? and apt_package_updates.length == 2
      apt_package_updates != ['0', '0']
    end
  end
end

Facter.add("apt_package_updates") do
  confine :apt_has_updates => true
  setcode do
    packages = Facter::Util::Resolution.exec('/usr/lib/update-notifier/apt-check -p 2>&1').split("\n")
    if Facter.version < '2.0.0'
      packages.join(',')
    else
      packages
    end
  end
end

Facter.add("apt_updates") do
  confine :apt_has_updates => true
  setcode do
    Integer(apt_package_updates[0])
  end
end

Facter.add("apt_security_updates") do
  confine :apt_has_updates => true
  setcode do
    Integer(apt_package_updates[1])
  end
end
