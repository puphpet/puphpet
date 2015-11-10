Puppet::Type.type(:rvm_system_ruby).provide(:rvm) do
  desc "Ruby RVM support."

  has_command(:rvmcmd, '/usr/local/rvm/bin/rvm') do
    environment :HOME => ENV['HOME']
  end

  def create
    unless resource[:proxy_url].nil?
      ENV['http_proxy'] = resource[:proxy_url]
      ENV['https_proxy'] = resource[:proxy_url]
      unless resource[:no_proxy].nil?
        ENV['no_proxy'] = resource[:no_proxy]
      end
    end
    set_autolib_mode if resource.value(:autolib_mode)
    options = Array(resource[:build_opts])
    if resource[:proxy_url] and !resource[:proxy_url].empty?
      rvmcmd "install", resource[:name], "--proxy", resource[:proxy_url], *options
    else
      rvmcmd "install", resource[:name], *options
    end
    set_default if resource.value(:default_use)
  end

  def destroy
    rvmcmd "uninstall", resource[:name]
  end

  def exists?
    begin
      rvmcmd("list", "strings").split("\n").any? do |line|
        line =~ Regexp.new(Regexp.escape(resource[:name]))
      end
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list RVMs: #{detail}"
    end

  end

  def default_use
    begin
      rvmcmd("list", "default").split("\n").any? do |line|
        line =~ Regexp.new(Regexp.escape(resource[:name]))
      end
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list default RVM: #{detail}"
    end
  end

  def default_use=(value)
    set_default if value
  end

  def set_default
    rvmcmd "alias", "create", "default", resource[:name]
  end

  def set_autolib_mode
    begin
      rvmcmd "autolibs", resource[:autolib_mode]
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not set autolib mode: #{detail}"
    end
  end
end
