# RVM gemset support
Puppet::Type.type(:rvm_alias).provide(:alias) do
  desc "RVM alias support."

  has_command(:rvmcmd, '/usr/local/rvm/bin/rvm') do
    environment :HOME => ENV['HOME']
  end

  def target_ruby
    resource[:target_ruby]
  end

  def alias_name
    resource[:name]
  end

  def aliascmd
    [command(:rvmcmd), "alias"]
  end

  def alias_list
    command = aliascmd + ['list']

    list = []
    begin
      list = execute(command)
    rescue Puppet::ExecutionFailure => detail
    end

    list.to_s
  end

  def create
    command = aliascmd + ['create', alias_name, target_ruby]
    execute(command)
  end

  def destroy
    command = aliascmd + ['delete', alias_name]
    execute(command)
  end

  def exists?
    alias_list.match("#{alias_name} => #{target_ruby}")
  end
end
