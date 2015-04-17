dir = File.dirname(File.expand_path(__FILE__))

require 'yaml'
require "#{dir}/puphpet/ruby/deep_merge.rb"

configValues = YAML.load_file("#{dir}/puphpet/config.yaml")

if File.file?("#{dir}/puphpet/config-custom.yaml")
  custom = YAML.load_file("#{dir}/puphpet/config-custom.yaml")
  configValues.deep_merge!(custom)
end

data = configValues['vagrantfile']

Vagrant.require_version '>= 1.6.0'

eval File.read("#{dir}/puphpet/vagrant/Vagrantfile-#{data['target']}")
