Puppet::Type.newtype(:mysql_plugin) do
  @doc = 'Manage MySQL plugins.'

  ensurable

  autorequire(:file) { '/root/.my.cnf' }

  newparam(:name, :namevar => true) do
    desc 'The name of the MySQL plugin to manage.'
  end

  newproperty(:soname) do
    desc 'The name of the library'
    newvalue(/^\w+\.\w+$/)
  end

end
