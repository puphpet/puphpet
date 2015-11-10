# RVM gemset support
Puppet::Type.type(:rvm_wrapper).provide(:wrapper) do
  desc "RVM wrapper support."

  has_command(:rvmcmd, '/usr/local/rvm/bin/rvm') do
    environment :HOME => ENV['HOME']
  end

  def target_ruby
    resource[:target_ruby]
  end

  def wrapper_name
    resource[:name]
  end

  def prefix
    resource[:prefix]
  end

  def wrapper_filename
    filename = prefix ? "#{prefix}_#{wrapper_name}" : wrapper_name
    "/usr/local/rvm/bin/#{filename}"
  end

  def create
    execute([command(:rvmcmd), "wrapper", target_ruby, prefix || "--no-prefix", wrapper_name])
  end

  def destroy
    File.delete wrapper_filename
  end

  def exists?
    File.exists? wrapper_filename
  end
end
