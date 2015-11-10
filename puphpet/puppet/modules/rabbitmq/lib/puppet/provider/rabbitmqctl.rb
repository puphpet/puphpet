class Puppet::Provider::Rabbitmqctl < Puppet::Provider
  initvars
  commands :rabbitmqctl => 'rabbitmqctl'

  def self.rabbitmq_version
    output = rabbitmqctl('-q', 'status')
    version = output.match(/\{rabbit,"RabbitMQ","([\d\.]+)"\}/)
    version[1] if version
  end

  # Retry the given code block 'count' retries or until the
  # command suceeeds. Use 'step' delay between retries.
  # Limit each query time by 'timeout'.
  # For example:
  #   users = self.class.run_with_retries { rabbitmqctl 'list_users' }
  def self.run_with_retries(count=30, step=6, timeout=10)
    count.times do |n|
      begin
        output = Timeout::timeout(timeout) do
          yield
        end
      rescue Puppet::ExecutionFailure, Timeout
        Puppet.debug 'Command failed, retrying'
        sleep step
      else
        Puppet.debug 'Command succeeded'
        return output
      end
    end
    raise Puppet::Error, "Command is still failing after #{count * step} seconds expired!"
  end

end
