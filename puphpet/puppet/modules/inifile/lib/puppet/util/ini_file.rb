require File.expand_path('../external_iterator', __FILE__)
require File.expand_path('../ini_file/section', __FILE__)

module Puppet
module Util
  class IniFile

    @@SECTION_REGEX = /^\s*\[([^\]]*)\]\s*$/
    @@SETTING_REGEX = /^(\s*)([\w\d\.\\\/\-\s\[\]\']*[\w\d\.\\\/\-\]])([ \t]*=[ \t]*)([\S\s]*?)\s*$/
    @@COMMENTED_SETTING_REGEX = /^(\s*)[#;]+(\s*)([\w\d\.\\\/\-\s\[\]\']*[\w\d\.\\\/\-\]])([ \t]*=[ \t]*)([\S\s]*?)\s*$/

    def initialize(path, key_val_separator = ' = ')
      @path = path
      @key_val_separator = key_val_separator
      @section_names = []
      @sections_hash = {}
      if File.file?(@path)
        parse_file
      end
    end

    def section_names
      @section_names
    end

    def get_settings(section_name)
      section = @sections_hash[section_name]
      section.setting_names.inject({}) do |result, setting|
        result[setting] = section.get_value(setting)
        result
      end
    end

    def get_value(section_name, setting)
      if (@sections_hash.has_key?(section_name))
        @sections_hash[section_name].get_value(setting)
      end
    end

    def set_value(section_name, setting, value)
      unless (@sections_hash.has_key?(section_name))
        add_section(Section.new(section_name, nil, nil, nil, nil))
      end

      section = @sections_hash[section_name]

      if (section.has_existing_setting?(setting))
        update_line(section, setting, value)
        section.update_existing_setting(setting, value)
      elsif result = find_commented_setting(section, setting)
        # So, this stanza is a bit of a hack.  What we're trying
        # to do here is this: for settings that don't already
        # exist, we want to take a quick peek to see if there
        # is a commented-out version of them in the section.
        # If so, we'd prefer to add the setting directly after
        # the commented line, rather than at the end of the section.

        # If we get here then we found a commented line, so we
        # call "insert_inline_setting_line" to update the lines array
        insert_inline_setting_line(result, section, setting, value)

        # Then, we need to tell the setting object that we hacked
        # in an inline setting
        section.insert_inline_setting(setting, value)

        # Finally, we need to update all of the start/end line
        # numbers for all of the sections *after* the one that
        # was modified.
        section_index = @section_names.index(section_name)
        increment_section_line_numbers(section_index + 1)
      else
        section.set_additional_setting(setting, value)
      end
    end

    def remove_setting(section_name, setting)
      section = @sections_hash[section_name]
      if (section.has_existing_setting?(setting))
        # If the setting is found, we have some work to do.
        # First, we remove the line from our array of lines:
        remove_line(section, setting)

        # Then, we need to tell the setting object to remove
        # the setting from its state:
        section.remove_existing_setting(setting)

        # Finally, we need to update all of the start/end line
        # numbers for all of the sections *after* the one that
        # was modified.
        section_index = @section_names.index(section_name)
        decrement_section_line_numbers(section_index + 1)
      end
    end

    def save
      File.open(@path, 'w') do |fh|

        @section_names.each_index do |index|
          name = @section_names[index]

          section = @sections_hash[name]

          # We need a buffer to cache lines that are only whitespace
          whitespace_buffer = []

          if (section.is_new_section?) && (! section.is_global?)
            fh.puts("\n[#{section.name}]")
          end

          if ! section.is_new_section?
            # write all of the pre-existing settings
            (section.start_line..section.end_line).each do |line_num|
              line = lines[line_num]

              # We buffer any lines that are only whitespace so that
              # if they are at the end of a section, we can insert
              # any new settings *before* the final chunk of whitespace
              # lines.
              if (line =~ /^\s*$/)
                whitespace_buffer << line
              else
                # If we get here, we've found a non-whitespace line.
                # We'll flush any cached whitespace lines before we
                # write it.
                flush_buffer_to_file(whitespace_buffer, fh)
                fh.puts(line)
              end
            end
          end

          # write new settings, if there are any
          section.additional_settings.each_pair do |key, value|
            fh.puts("#{' ' * (section.indentation || 0)}#{key}#{@key_val_separator}#{value}")
          end

          if (whitespace_buffer.length > 0)
            flush_buffer_to_file(whitespace_buffer, fh)
          else
            # We get here if there were no blank lines at the end of the
            # section.
            #
            # If we are adding a new section with a new setting,
            # and if there are more sections that come after this one,
            # we'll write one blank line just so that there is a little
            # whitespace between the sections.
            #if (section.end_line.nil? &&
            if (section.is_new_section? &&
                (section.additional_settings.length > 0) &&
                (index < @section_names.length - 1))
              fh.puts("")
            end
          end

        end
      end
    end


    private
    def add_section(section)
      @sections_hash[section.name] = section
      @section_names << section.name
    end

    def parse_file
      line_iter = create_line_iter

      # We always create a "global" section at the beginning of the file, for
      # anything that appears before the first named section.
      section = read_section('', 0, line_iter)
      add_section(section)
      line, line_num = line_iter.next

      while line
        if (match = @@SECTION_REGEX.match(line))
          section = read_section(match[1], line_num, line_iter)
          add_section(section)
        end
        line, line_num = line_iter.next
      end
    end

    def read_section(name, start_line, line_iter)
      settings = {}
      end_line_num = nil
      min_indentation = nil
      while true
        line, line_num = line_iter.peek
        if (line_num.nil? or match = @@SECTION_REGEX.match(line))
          return Section.new(name, start_line, end_line_num, settings, min_indentation)
        elsif (match = @@SETTING_REGEX.match(line))
          settings[match[2]] = match[4]
          indentation = match[1].length
          min_indentation = [indentation, min_indentation || indentation].min
        end
        end_line_num = line_num
        line_iter.next
      end
    end

    def update_line(section, setting, value)
      (section.start_line..section.end_line).each do |line_num|
        if (match = @@SETTING_REGEX.match(lines[line_num]))
          if (match[2] == setting)
            lines[line_num] = "#{match[1]}#{match[2]}#{match[3]}#{value}"
          end
        end
      end
    end

    def remove_line(section, setting)
      (section.start_line..section.end_line).each do |line_num|
        if (match = @@SETTING_REGEX.match(lines[line_num]))
          if (match[2] == setting)
            lines.delete_at(line_num)
          end
        end
      end
    end

    def create_line_iter
      ExternalIterator.new(lines)
    end

    def lines
        @lines ||= IniFile.readlines(@path)
    end

    # This is mostly here because it makes testing easier--we don't have
    #  to try to stub any methods on File.
    def self.readlines(path)
        # If this type is ever used with very large files, we should
        #  write this in a different way, using a temp
        #  file; for now assuming that this type is only used on
        #  small-ish config files that can fit into memory without
        #  too much trouble.
        File.readlines(path)
    end

    # This utility method scans through the lines for a section looking for
    # commented-out versions of a setting.  It returns `nil` if it doesn't
    # find one.  If it does find one, then it returns a hash containing
    # two keys:
    #
    #   :line_num - the line number that contains the commented version
    #               of the setting
    #   :match    - the ruby regular expression match object, which can
    #               be used to mimic the whitespace from the comment line
    def find_commented_setting(section, setting)
      return nil if section.is_new_section?
      (section.start_line..section.end_line).each do |line_num|
        if (match = @@COMMENTED_SETTING_REGEX.match(lines[line_num]))
          if (match[3] == setting)
            return { :match => match, :line_num => line_num }
          end
        end
      end
      nil
    end

    # This utility method is for inserting a line into the existing
    # lines array.  The `result` argument is expected to be in the
    # format of the return value of `find_commented_setting`.
    def insert_inline_setting_line(result, section, setting, value)
      line_num = result[:line_num]
      match = result[:match]
      lines.insert(line_num + 1, "#{' ' * (section.indentation || 0 )}#{setting}#{match[4]}#{value}")
    end

    # Utility method; given a section index (index into the @section_names
    # array), decrement the start/end line numbers for that section and all
    # all of the other sections that appear *after* the specified section.
    def decrement_section_line_numbers(section_index)
      @section_names[section_index..(@section_names.length - 1)].each do |name|
        section = @sections_hash[name]
        section.decrement_line_nums
      end
    end

    # Utility method; given a section index (index into the @section_names
    # array), increment the start/end line numbers for that section and all
    # all of the other sections that appear *after* the specified section.
    def increment_section_line_numbers(section_index)
      @section_names[section_index..(@section_names.length - 1)].each do |name|
        section = @sections_hash[name]
        section.increment_line_nums
      end
    end


    def flush_buffer_to_file(buffer, fh)
      if buffer.length > 0
        buffer.each { |l| fh.puts(l) }
        buffer.clear
      end
    end

  end
end
end
