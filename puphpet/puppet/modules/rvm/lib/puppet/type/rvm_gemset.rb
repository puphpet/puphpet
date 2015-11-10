Puppet::Type.newtype(:rvm_gemset) do
  @doc = "Manage RVM Gemsets."

  def self.title_patterns
    [ [ /^(?:(.*)@)?(.*)$/, [ [ :ruby_version, lambda{|x| x} ], [ :name, lambda{|x| x} ] ] ] ]
  end

  ensurable

  autorequire(:rvm_system_ruby) do
    [self[:ruby_version]]
  end

  newparam(:name) do
    desc "The name of the gemset to be managed."
    isnamevar
  end

  newparam(:ruby_version) do
    desc "The ruby version to use.  This should be the fully qualified RVM string.
    For example: 'ruby-1.9.2-p290'
    For a full list of known strings: `rvm list known_strings`."

    defaultto "1.9"
    isnamevar
  end

  newparam(:proxy_url) do
    desc "Proxy to use when downloading ruby installation"
    defaultto ""
  end

end
