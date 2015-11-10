Facter.add("rvm_version") do
  rvm_binary = "/usr/local/rvm/bin/rvm"

  setcode do
    File.exists?(rvm_binary) ? `#{rvm_binary} version`.strip.match(/rvm ([0-9]+\.[0-9]+\.[0-9]+) .*/)[1] : nil
  end
end
