require 'uri'
require 'stringio'
require 'time'

module URI
  class FTP
    def buffer_open(buf, proxy, options) # :nodoc:
      if proxy
        OpenURI.open_http(buf, self, proxy, options)
        return
      end
      require 'net/ftp'

      directories = self.path.split(%r{/}, -1)
      directories.shift if directories[0] == '' # strip a field before leading slash
      directories.each {|d|
        d.gsub!(/%([0-9A-Fa-f][0-9A-Fa-f])/) { [$1].pack("H2") }
      }
      unless filename = directories.pop
        raise ArgumentError, "no filename: #{self.inspect}"
      end
      directories.each {|d|
        if /[\r\n]/ =~ d
          raise ArgumentError, "invalid directory: #{d.inspect}"
        end
      }
      if /[\r\n]/ =~ filename
        raise ArgumentError, "invalid filename: #{filename.inspect}"
      end
      typecode = self.typecode
      if typecode && /\A[aid]\z/ !~ typecode
        raise ArgumentError, "invalid typecode: #{typecode.inspect}"
      end

      # The access sequence is defined by RFC 1738
      ftp = Net::FTP.open(self.host)
      ftp.passive = true if !options[:ftp_active_mode]
      # todo: extract user/passwd from .netrc.
      user = 'anonymous'
      passwd = nil
      user, passwd = self.userinfo.split(/:/) if self.userinfo
      ftp.login(user, passwd)
      directories.each {|cwd|
        ftp.voidcmd("CWD #{cwd}")
      }
      if typecode
        # xxx: typecode D is not handled.
        ftp.voidcmd("TYPE #{typecode.upcase}")
      end
      if options[:content_length_proc]
        options[:content_length_proc].call(ftp.size(filename))
      end
      ftp.retrbinary("RETR #{filename}", 4096) { |str|
        buf << str
        options[:progress_proc].call(buf.size) if options[:progress_proc]
      }
      ftp.close
      buf.io.rewind
    end

    include OpenURI::OpenRead
  end
end
