require 'spec_helper_acceptance'

tmpdir = default.tmpdir('tmp')

describe 'ini_subsetting resource' do
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
      apply_manifest(pp, :catch_changes  => true)
    end

    describe file(path) do
      it { should be_file }
      it { should contain(content) }
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

  describe 'ensure, section, setting, subsetting, & value parameters' do
    context '=> present with subsections' do
      pp = <<-EOS
      ini_subsetting { 'ensure => present for alpha':
        ensure     => present,
        path       => "#{tmpdir}/ini_subsetting.ini",
        section    => 'one',
        setting    => 'key',
        subsetting => 'alpha',
        value      => 'bet',
      }
      ini_subsetting { 'ensure => present for beta':
        ensure     => present,
        path       => "#{tmpdir}/ini_subsetting.ini",
        section    => 'one',
        setting    => 'key',
        subsetting => 'beta',
        value      => 'trons',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/ini_subsetting.ini") do
        it { should be_file }
        #XXX Solaris 10 doesn't support multi-line grep
        it("should contain [one]\nkey = alphabet betatrons", :unless => fact('osfamily') == 'Solaris') {
          should contain("[one]\nkey = alphabet betatrons")
        }
      end
    end

    context 'ensure => absent' do
      before :all do
        if fact('osfamily') == 'Darwin'
          shell("echo \"[one]\nkey = alphabet betatrons\" > #{tmpdir}/ini_subsetting.ini")
        else
          shell("echo -e \"[one]\nkey = alphabet betatrons\" > #{tmpdir}/ini_subsetting.ini")
        end
      end

      pp = <<-EOS
      ini_subsetting { 'ensure => absent for subsetting':
        ensure     => absent,
        path       => "#{tmpdir}/ini_subsetting.ini",
        section    => 'one',
        setting    => 'key',
        subsetting => 'alpha',
      }
      EOS

      it 'applies the manifest twice' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end

      describe file("#{tmpdir}/ini_subsetting.ini") do
        it { should be_file }
        it { should contain('[one]') }
        it { should contain('key = betatrons') }
        it { should_not contain('alphabet') }
      end
    end
  end

  describe 'subsetting_separator' do
    {
      ""                                => "two = twinethree foobar",
      #"subsetting_separator => '',"     => "two = twinethreefoobar", # breaks regex
      "subsetting_separator => ',',"    => "two = twinethree,foobar",
      "subsetting_separator => '   ',"  => "two = twinethree   foobar",
      "subsetting_separator => ' == '," => "two = twinethree == foobar",
      "subsetting_separator => '=',"    => "two = twinethree=foobar",
      #"subsetting_separator => '---',"  => "two = twinethree---foobar", # breaks regex
    }.each do |parameter, content|
      context "with \"#{parameter}\" makes \"#{content}\"" do
        pp = <<-EOS
        ini_subsetting { "with #{parameter} makes #{content}":
          ensure     => present,
          section    => 'one',
          setting    => 'two',
          subsetting => 'twine',
          value      => 'three',
          path       => "#{tmpdir}/subsetting_separator.ini",
          #{parameter}
        }
        ini_subsetting { "foobar":
          ensure     => present,
          section    => 'one',
          setting    => 'two',
          subsetting => 'foo',
          value      => 'bar',
          path       => "#{tmpdir}/subsetting_separator.ini",
          #{parameter}
        }
        EOS

        it_behaves_like 'has_content', "#{tmpdir}/subsetting_separator.ini", pp, content
      end
    end
  end

  describe 'quote_char' do
    {
      ['-Xmx']         => 'args=""',
      ['-Xmx', '256m'] => 'args=-Xmx256m',
      ['-Xmx', '512m'] => 'args="-Xmx512m"',
      ['-Xms', '256m'] => 'args="-Xmx256m -Xms256m"',
    }.each do |parameter, content|
      context %Q{with '#{parameter.first}' #{parameter.length > 1 ? '=> \'' << parameter[1] << '\'' : 'absent'} makes '#{content}'} do
        path = File.join(tmpdir, 'ini_subsetting.ini')

        before :all do
          shell(%Q{echo '[java]\nargs=-Xmx256m' > #{path}})
        end
        after :all do
          shell("cat #{path}", :acceptable_exit_codes => [0,1,2])
          shell("rm #{path}", :acceptable_exit_codes => [0,1,2])
        end

        pp = <<-EOS
        ini_subsetting { '#{parameter.first}':
          ensure     => #{parameter.length > 1 ? 'present' : 'absent'},
          path       => '#{path}',
          section    => 'java',
          setting    => 'args',
          quote_char => '"',
          subsetting => '#{parameter.first}',
          value      => '#{parameter.length > 1 ? parameter[1] : ''}'
        }
        EOS

        it 'applies the manifest twice' do
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end

        describe file("#{tmpdir}/ini_subsetting.ini") do
          it { should be_file }
          it { should contain(content) }
        end
      end
    end
  end
end
