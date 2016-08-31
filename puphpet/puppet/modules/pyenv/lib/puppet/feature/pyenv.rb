require 'puppet/util/feature'

Puppet.features.add(:pyenv) {
  if not Facter.value('pyenv_binary').nil?
    File.executable?(Facter.value('pyenv_binary'))
  else
    true
  end
}
