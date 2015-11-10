Puppet::Type.newtype(:rabbitmq_erlang_cookie) do
  desc 'Type to manage the rabbitmq erlang cookie securely'

  newparam(:path, :namevar => true)

  newproperty(:content) do
    desc 'Content of cookie'
    newvalues(/^\S+$/)
    def change_to_s(current, desired)
      "The rabbitmq erlang cookie was changed"
    end
  end

  newparam(:force) do
    defaultto(:false)
    newvalues(:true, :false)
  end

  newparam(:rabbitmq_user) do
    defaultto('rabbitmq')
  end

  newparam(:rabbitmq_group) do
    defaultto('rabbitmq')
  end

  newparam(:rabbitmq_home) do
    defaultto('/var/lib/rabbitmq')
  end

  newparam(:service_name) do
    newvalues(/^\S+$/)
  end
end
