Puppet::Type.newtype(:rvm_wrapper) do
  @doc = "Manage RVM Wrappers."

  ensurable

  newparam(:name) do
    desc "The name of the command to create a wrapper for to be managed."
    isnamevar
  end

  newparam(:prefix) do
    desc "The prefix of the wrapper command to be managed."
  end

  newparam(:target_ruby) do
    desc "The ruby version that is the target of our wrapper.
    For example: 'ruby-1.9.2-p290'"
  end

end
