require 'spec_helper_acceptance'

describe 'deprecation warnings' do
  basedir = default.tmpdir('concat')

  shared_examples 'has_warning'do |pp, w|
    it 'applies the manifest twice with a stderr regex' do
      expect(apply_manifest(pp, :catch_failures => true).stderr).to match(/#{Regexp.escape(w)}/m)
      expect(apply_manifest(pp, :catch_changes => true).stderr).to match(/#{Regexp.escape(w)}/m)
    end
  end

  context 'concat gnu parameter' do
    pp = <<-EOS
      concat { '#{basedir}/file':
        gnu => 'foo',
      }
      concat::fragment { 'foo':
        target  => '#{basedir}/file',
        content => 'bar',
      }
    EOS
    w = 'The $gnu parameter to concat is deprecated and has no effect'

    it_behaves_like 'has_warning', pp, w
  end

  context 'concat warn parameter =>' do
    ['true', 'yes', 'on'].each do |warn|
      context warn do
        pp = <<-EOS
          concat { '#{basedir}/file':
            warn => '#{warn}',
          }
          concat::fragment { 'foo':
            target  => '#{basedir}/file',
            content => 'bar',
          }
        EOS
        w = 'Using stringified boolean values (\'true\', \'yes\', \'on\', \'false\', \'no\', \'off\') to represent boolean true/false as the $warn parameter to concat is deprecated and will be treated as the warning message in a future release'

        it_behaves_like 'has_warning', pp, w

        describe file("#{basedir}/file") do
          it { should be_file }
          it { should contain '# This file is managed by Puppet. DO NOT EDIT.' }
          it { should contain 'bar' }
        end
      end
    end

    ['false', 'no', 'off'].each do |warn|
      context warn do
        pp = <<-EOS
          concat { '#{basedir}/file':
            warn => '#{warn}',
          }
          concat::fragment { 'foo':
            target  => '#{basedir}/file',
            content => 'bar',
          }
        EOS
        w = 'Using stringified boolean values (\'true\', \'yes\', \'on\', \'false\', \'no\', \'off\') to represent boolean true/false as the $warn parameter to concat is deprecated and will be treated as the warning message in a future release'

        it_behaves_like 'has_warning', pp, w

        describe file("#{basedir}/file") do
          it { should be_file }
          it { should_not contain '# This file is managed by Puppet. DO NOT EDIT.' }
          it { should contain 'bar' }
        end
      end
    end
  end

  context 'concat::fragment ensure parameter' do
    context 'target file exists' do
      before(:all) do
        shell("/bin/echo 'file1 contents' > #{basedir}/file1")
        pp = <<-EOS
          file { '#{basedir}':
            ensure => directory,
          }
          file { '#{basedir}/file1':
            content => "file1 contents\n",
          }
        EOS
        apply_manifest(pp)
      end

      pp = <<-EOS
        concat { '#{basedir}/file': }
        concat::fragment { 'foo':
          target => '#{basedir}/file',
          ensure => '#{basedir}/file1',
        }
      EOS
      w = 'Passing a value other than \'present\' or \'absent\' as the $ensure parameter to concat::fragment is deprecated.  If you want to use the content of a file as a fragment please use the $source parameter.'

      it_behaves_like 'has_warning', pp, w

      describe file("#{basedir}/file") do
        it { should be_file }
        it { should contain 'file1 contents' }
      end

      describe 'the fragment can be changed from a symlink to a plain file', :unless => (fact("osfamily") == "windows") do
        pp = <<-EOS
          concat { '#{basedir}/file': }
          concat::fragment { 'foo':
            target  => '#{basedir}/file',
            content => 'new content',
          }
        EOS

        it 'applies the manifest twice with no stderr' do
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => true)
        end

        describe file("#{basedir}/file") do
          it { should be_file }
          it { should contain 'new content' }
          it { should_not contain 'file1 contents' }
        end
      end
    end # target file exists

    context 'target does not exist' do
      pp = <<-EOS
        concat { '#{basedir}/file': }
        concat::fragment { 'foo':
          target => '#{basedir}/file',
          ensure => '#{basedir}/file1',
        }
      EOS
      w = 'Passing a value other than \'present\' or \'absent\' as the $ensure parameter to concat::fragment is deprecated.  If you want to use the content of a file as a fragment please use the $source parameter.'

      it_behaves_like 'has_warning', pp, w

      describe file("#{basedir}/file") do
        it { should be_file }
      end

      describe 'the fragment can be changed from a symlink to a plain file', :unless => (fact('osfamily') == 'windows') do
        pp = <<-EOS
          concat { '#{basedir}/file': }
          concat::fragment { 'foo':
            target  => '#{basedir}/file',
            content => 'new content',
          }
        EOS

        it 'applies the manifest twice with no stderr' do
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes => true)
        end

        describe file("#{basedir}/file") do
          it { should be_file }
          it { should contain 'new content' }
        end
      end
    end # target file exists

  end # concat::fragment ensure parameter

  context 'concat::fragment mode parameter' do
    pp = <<-EOS
      concat { '#{basedir}/file': }
      concat::fragment { 'foo':
        target  => '#{basedir}/file',
        content => 'bar',
        mode    => 'bar',
      }
    EOS
    w = 'The $mode parameter to concat::fragment is deprecated and has no effect'

    it_behaves_like 'has_warning', pp, w
  end

  context 'concat::fragment owner parameter' do
    pp = <<-EOS
      concat { '#{basedir}/file': }
      concat::fragment { 'foo':
        target  => '#{basedir}/file',
        content => 'bar',
        owner   => 'bar',
      }
    EOS
    w = 'The $owner parameter to concat::fragment is deprecated and has no effect'

    it_behaves_like 'has_warning', pp, w
  end

  context 'concat::fragment group parameter' do
    pp = <<-EOS
      concat { '#{basedir}/file': }
      concat::fragment { 'foo':
        target  => '#{basedir}/file',
        content => 'bar',
        group   => 'bar',
      }
    EOS
    w = 'The $group parameter to concat::fragment is deprecated and has no effect'

    it_behaves_like 'has_warning', pp, w
  end

  context 'concat::fragment backup parameter' do
    pp = <<-EOS
      concat { '#{basedir}/file': }
      concat::fragment { 'foo':
        target  => '#{basedir}/file',
        content => 'bar',
        backup  => 'bar',
      }
    EOS
    w = 'The $backup parameter to concat::fragment is deprecated and has no effect'

    it_behaves_like 'has_warning', pp, w
  end

  context 'include concat::setup' do
    pp = <<-EOS
      include concat::setup
    EOS
    w = 'concat::setup is deprecated as a public API of the concat module and should no longer be directly included in the manifest.'

    it_behaves_like 'has_warning', pp, w
  end

end
