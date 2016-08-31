require 'puppet'
require 'set'
Puppet::Type.type(:rabbitmq_erlang_cookie).provide(:ruby) do

  defaultfor :feature => :posix
  has_command(:puppet, 'puppet') do
    environment :PATH => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  end

  def exists?
    # Hack to prevent the create method from being called.
    # We never need to create or destroy this resource, only change its value
    true
  end

  def content=(value)
    if resource[:force] == :true # Danger!
      puppet('resource', 'service', resource[:service_name], 'ensure=stopped')
      FileUtils.rm_rf(resource[:rabbitmq_home] + File::PATH_SEPARATOR + 'mnesia')
      File.open(resource[:path], 'w') do |cookie|
        cookie.chmod(0400)
        cookie.write(value)
      end
      FileUtils.chown(resource[:rabbitmq_user], resource[:rabbitmq_group], resource[:path])
    else
      fail("The current erlang cookie needs to change. In order to do this the RabbitMQ database needs to be wiped.  Please set force => true to allow this to happen automatically.")
    end
  end

  def content
    if File.exists?(resource[:path])
      File.read(resource[:path])
    else
      ''
    end
  end

end
