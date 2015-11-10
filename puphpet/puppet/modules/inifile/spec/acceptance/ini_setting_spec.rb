require 'spec_helper_acceptance'

tmpdir = default.tmpdir('tmp')

describe 'ini_setting resource' do
  after :all do
    shell("rm #{tmpdir}/*.ini", :acceptable_exit_codes => [0,1,2])
  end

  shared_examples 'has_content' do |path,pp,content|
    before :all do
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end
    after :all do
      shell("cat #{path}", :acceptable_exit_codes => [0,1,2])
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end

    it 'applies the manifest twice' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file(path) do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain #{content}", :unless => fact('osfamily') == 'Solaris') {
        should contain(content)
      }
    end
  end

  shared_examples 'has_error' do |path,pp,error|
    before :all do
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end
    after :all do
      shell("cat #{path}", :acceptable_exit_codes => [0,1,2])
      shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
    end

    it 'applies the manifest and gets a failure message' do
      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(error)
    end

    describe file(path) do
      it { should_not be_file }
    end
  end

  describe 'ensure parameter' do
    context '=> present for global and section' do
      pp = <<-EOS
      ini_setting { 'ensure => present for section':
        ensure  => present,
        path    => "#{tmpdir}/ini_setting.ini",
        section => 'one',
        setting => 'two',
        value   => 'three',
      }
      ini_setting { 'ensure => present for global':
        ensure  => present,
        path    => "#{tmpdir}/ini_setting.ini",
        section => '',
        setting => 'four',
        value   => 'five',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{tmpdir}/ini_setting.ini") do
        it { should be_file }
        #XXX Solaris 10 doesn't support multi-line grep
        it("should contain four = five\n[one]\ntwo = three", :unless => fact('osfamily') == 'Solaris') {
          should contain("four = five\n[one]\ntwo = three")
        }
      end
    end

    context '=> absent for key/value' do
      before :all do
        if fact('osfamily') == 'Darwin'
          shell("echo \"four = five\n[one]\ntwo = three\" > #{tmpdir}/ini_setting.ini")
        else
          shell("echo -e \"four = five\n[one]\ntwo = three\" > #{tmpdir}/ini_setting.ini")
        end
      end

      pp = <<-EOS
      ini_setting { 'ensure => absent for key/value':
        ensure  => absent,
        path    => "#{tmpdir}/ini_setting.ini",
        section => 'one',
        setting => 'two',
        value   => 'three',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/ini_setting.ini") do
        it { should be_file }
        it { should contain('four = five') }
        it { should contain('[one]') }
        it { should_not contain('two = three') }
      end
    end

    context '=> absent for section', :pending => "cannot ensure absent on a section"  do
      before :all do
        if fact('osfamily') == 'Darwin'
          shell("echo \"four = five\n[one]\ntwo = three\" > #{tmpdir}/ini_setting.ini")
        else
          shell("echo -e \"four = five\n[one]\ntwo = three\" > #{tmpdir}/ini_setting.ini")
        end
      end
      after :all do
        shell("cat #{tmpdir}/ini_setting.ini", :acceptable_exit_codes => [0,1,2])
        shell("rm #{tmpdir}/ini_setting.ini", :acceptable_exit_codes => [0,1,2])
      end

      pp = <<-EOS
      ini_setting { 'ensure => absent for section':
        ensure  => absent,
        path    => "#{tmpdir}/ini_setting.ini",
        section => 'one',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/ini_setting.ini") do
        it { should be_file }
        it { should contain('four = five') }
        it { should_not contain('[one]') }
        it { should_not contain('two = three') }
      end
    end

    context '=> absent for global' do
      before :all do
        if fact('osfamily') == 'Darwin'
          shell("echo \"four = five\n[one]\ntwo = three\" > #{tmpdir}/ini_setting.ini")
        else
          shell("echo -e \"four = five\n[one]\ntwo = three\" > #{tmpdir}/ini_setting.ini")
        end
      end
      after :all do
        shell("cat #{tmpdir}/ini_setting.ini", :acceptable_exit_codes => [0,1,2])
        shell("rm #{tmpdir}/ini_setting.ini", :acceptable_exit_codes => [0,1,2])
      end

      pp = <<-EOS
      ini_setting { 'ensure => absent for global':
        ensure  => absent,
        path    => "#{tmpdir}/ini_setting.ini",
        section => '',
        setting => 'four',
        value   => 'five',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/ini_setting.ini") do
        it { should be_file }
        it { should_not contain('four = five') }
        it { should contain('[one]') }
        it { should contain('two = three') }
      end
    end
  end

  describe 'section, setting, value parameters' do
    {
      "section => 'test', setting => 'foo', value => 'bar',"   => "[test]\nfoo = bar",
      "section => 'more', setting => 'baz', value => 'quux',"  => "[more]\nbaz = quux",
      "section => '',     setting => 'top', value => 'level'," => "top = level",
    }.each do |parameter_list, content|
      context parameter_list do
        pp = <<-EOS
        ini_setting { "#{parameter_list}":
          ensure  => present,
          path    => "#{tmpdir}/ini_setting.ini",
          #{parameter_list}
        }
        EOS

        it_behaves_like 'has_content', "#{tmpdir}/ini_setting.ini", pp, content
      end
    end

    {
      "section => 'test',"                   => /setting is a required.+value is a required/,
      "setting => 'foo',  value   => 'bar'," => /section is a required/,
      "section => 'test', setting => 'foo'," => /value is a required/,
      "section => 'test', value   => 'bar'," => /setting is a required/,
      "value   => 'bar',"                    => /section is a required.+setting is a required/,
      "setting => 'foo',"                    => /section is a required.+value is a required/,
    }.each do |parameter_list, error|
      context parameter_list, :pending => 'no error checking yet' do
        pp = <<-EOS
        ini_setting { "#{parameter_list}":
          ensure  => present,
          path    => "#{tmpdir}/ini_setting.ini",
          #{parameter_list}
        }
        EOS

        it_behaves_like 'has_error', "#{tmpdir}/ini_setting.ini", pp, error
      end
    end
  end

  describe 'path parameter' do
    [
      "#{tmpdir}/one.ini",
      "#{tmpdir}/two.ini",
      "#{tmpdir}/three.ini",
    ].each do |path|
      context "path => #{path}" do
        pp = <<-EOS
        ini_setting { 'path => #{path}':
          ensure  => present,
          section => 'one',
          setting => 'two',
          value   => 'three',
          path    => '#{path}',
        }
        EOS

        it_behaves_like 'has_content', path, pp, "[one]\ntwo = three"
      end
    end

    context "path => foo" do
      pp = <<-EOS
        ini_setting { 'path => foo':
          ensure     => present,
          section    => 'one',
          setting    => 'two',
          value      => 'three',
          path       => 'foo',
        }
      EOS

      it_behaves_like 'has_error', 'foo', pp, /must be fully qualified/
    end
  end

  describe 'key_val_separator parameter' do
    {
      ""                             => "two = three",
      "key_val_separator => '=',"    => "two=three",
      "key_val_separator => ' =  '," => "two =  three",
    }.each do |parameter, content|
      context "with \"#{parameter}\" makes \"#{content}\"" do
        pp = <<-EOS
        ini_setting { "with #{parameter} makes #{content}":
          ensure  => present,
          section => 'one',
          setting => 'two',
          value   => 'three',
          path    => "#{tmpdir}/key_val_separator.ini",
          #{parameter}
        }
        EOS

        it_behaves_like 'has_content', "#{tmpdir}/key_val_separator.ini", pp, content
      end
    end

    {
      "key_val_separator => '',"      => /must contain exactly one/,
      "key_val_separator => ',',"     => /must contain exactly one/,
      "key_val_separator => '   ',"   => /must contain exactly one/,
      "key_val_separator => ' ==  '," => /must contain exactly one/,
    }.each do |parameter, error|
      context "with \"#{parameter}\" raises \"#{error}\"" do
        pp = <<-EOS
        ini_setting { "with #{parameter} raises #{error}":
          ensure  => present,
          section => 'one',
          setting => 'two',
          value   => 'three',
          path    => "#{tmpdir}/key_val_separator.ini",
          #{parameter}
        }
        EOS

        it_behaves_like 'has_error', "#{tmpdir}/key_val_separator.ini", pp, error
      end
    end
  end
end
