Puppet::Type.newtype(:rvm_gem) do
  @doc = "Ruby Gem support using RVM."

  def self.title_patterns
    [ [ /^(?:(.*)\/)?(.*)$/, [ [ :ruby_version, lambda{|x| x} ], [ :name, lambda{|x| x} ] ] ] ]
  end

  ensurable do
    desc "What state the gem should be in.
      Possible values:
        *present* - the gem is installed
        *latest* - the gem is installed and is the latest stable version
        *absent* - the gem is not installed
        version - the gem is installed and matches the given version"

    attr_accessor :latest

    newvalue(:present, :event => :package_installed) do
      provider.install
    end

    newvalue(:absent, :event => :package_removed) do
      provider.uninstall
    end

    # Alias the 'present' value.
    aliasvalue(:installed, :present)

    newvalue(:latest) do
      current = self.retrieve
      begin
        provider.update
      rescue => detail
        self.fail "Could not update: #{detail}"
      end

      if current == :absent
        :package_installed
      else
        :package_changed
      end
    end

    newvalue(/./) do
      begin
        provider.install
      rescue => detail
        self.fail "Could not update: #{detail}"
      end

      if self.retrieve == :absent
        :package_installed
      else
        :package_changed
      end
    end

    def insync?(is)
      @should ||= []

      @latest ||= nil
      @lateststamp ||= (Time.now.to_i - 1000)
      # Iterate across all of the should values, and see how they
      # turn out.

      @should.each { |should|
        case should
        when :present
          return true unless is == :absent
        when :latest
          # Short-circuit packages that are not present
          return false if is == :absent

          # Don't run 'latest' more than about every 5 minutes
          if @latest and ((Time.now.to_i - @lateststamp) / 60) < 5
            #self.debug "Skipping latest check"
          else
            begin
              @latest = provider.latest
              @lateststamp = Time.now.to_i
            rescue => detail
              error = Puppet::Error.new("Could not get latest version: #{detail}")
              error.set_backtrace(detail.backtrace)
              raise error
            end
          end

          case is
          when is.is_a?(Array)
            if is.include?(@latest)
              return true
            else
              return false
            end
          when @latest
            return true
          else
            self.debug "#{@resource.name} #{is.inspect} is installed, latest is #{@latest.inspect}"
          end
        when :absent
          return true if is == :absent
        when *Array(is)
          return true
        end
      }

      false
    end

    def retrieve
      if gem = provider.query
        gem[:ensure]
      else
        :absent
      end
    end

    defaultto :installed

  end

  autorequire(:rvm_system_ruby) do
    [self[:ruby_version].split("@").first]
  end

  newparam(:name) do
    desc "The name of the Ruby gem."

    isnamevar
  end

  newparam(:withopts) do
    desc "Install the gem with these makefile opts."
  end

  newparam(:source) do
    desc "If a URL is passed via, then that URL is used as the
    remote gem repository; if a source is present but is not a valid URL, it will be
    interpreted as the path to a local gem file.  If source is not present at all,
    the gem will be installed from the default gem repositories."
  end

  newparam(:ruby_version) do
    desc "The ruby version to use.  This should be the fully qualified RVM string
    (including gemset if applicable).  For example: 'ruby-1.9.2-p136@mygemset'
    For a full list of known strings: `rvm list known_strings`."

    defaultto "1.9"
    isnamevar
  end

  newparam(:proxy_url) do
    desc "Proxy to use when downloading ruby installation"
    defaultto ""
  end 

end
