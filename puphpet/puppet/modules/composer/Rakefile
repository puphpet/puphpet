require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'

namespace :vagrant do
  desc 'Bring up the developement VM'
  task :up => [:spec_prep, :remove_symlink] do
    system 'vagrant up'
  end

  desc 'Run Puppet provisioner on the VM'
  task :provision => [:spec_prep, :remove_symlink] do
    system 'vagrant provision'
  end

  desc 'Destroy the VM'
  task :destroy do
    system 'vagrant destroy'
  end

  desc 'Check the VM status'
  task :status do
    system 'vagrant status'
  end

  desc 'Reload the VM with new mounts'
  task :reload => [:spec_prep, :remove_symlink] do
    system 'vagrant reload'
  end

  desc 'Remove the fixtures symlink to composer'
  task :remove_symlink do
    fixtures('symlinks').each do |source, target|
      FileUtils::rm(target)
    end
  end
end
