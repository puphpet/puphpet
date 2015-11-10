Puppet::Type.newtype(:inherit_ini_setting) do
  ensurable
  newparam(:setting, :namevar => true)
  newproperty(:value)
end
