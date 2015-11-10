require 'spec_helper_acceptance'

describe 'replacement of' do
  basedir = default.tmpdir('concat')
  context 'file' do
    context 'should not succeed' do
      before(:all) do
        pp = <<-EOS
          file { '#{basedir}':
            ensure => directory,
          }
          file { '#{basedir}/file':
            content => "file exists\n"
          }
        EOS
        apply_manifest(pp)
      end
      pp = <<-EOS
        concat { '#{basedir}/file':
          replace => false,
        }

        concat::fragment { '1':
          target  => '#{basedir}/file',
          content => '1',
        }

        concat::fragment { '2':
          target  => '#{basedir}/file',
          content => '2',
        }
      EOS

      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{basedir}/file") do
        it { should be_file }
        it { should contain 'file exists' }
        it { should_not contain '1' }
        it { should_not contain '2' }
      end
    end

    context 'should succeed' do
      before(:all) do
        pp = <<-EOS
          file { '#{basedir}':
            ensure => directory,
          }
          file { '#{basedir}/file':
            content => "file exists\n"
          }
        EOS
        apply_manifest(pp)
      end
      pp = <<-EOS
        concat { '#{basedir}/file':
          replace => true,
        }

        concat::fragment { '1':
          target  => '#{basedir}/file',
          content => '1',
        }

        concat::fragment { '2':
          target  => '#{basedir}/file',
          content => '2',
        }
      EOS

      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{basedir}/file") do
        it { should be_file }
        it { should_not contain 'file exists' }
        it { should contain '1' }
        it { should contain '2' }
      end
    end
  end # file

  context 'symlink', :unless => (fact("osfamily") == "windows") do
    context 'should not succeed' do
      # XXX the core puppet file type will replace a symlink with a plain file
      # when using ensure => present and source => ... but it will not when using
      # ensure => present and content => ...; this is somewhat confusing behavior
      before(:all) do
        pp = <<-EOS
          file { '#{basedir}':
            ensure => directory,
          }
          file { '#{basedir}/file':
            ensure => link,
            target => '#{basedir}/dangling',
          }
        EOS
        apply_manifest(pp)
      end

      pp = <<-EOS
        concat { '#{basedir}/file':
          replace => false,
        }

        concat::fragment { '1':
          target  => '#{basedir}/file',
          content => '1',
        }

        concat::fragment { '2':
          target  => '#{basedir}/file',
          content => '2',
        }
      EOS

      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      # XXX specinfra doesn't support be_linked_to on AIX
      describe file("#{basedir}/file"), :unless => (fact("osfamily") == "AIX") do
        it { should be_linked_to "#{basedir}/dangling" }
      end

      describe file("#{basedir}/dangling") do
        # XXX serverspec does not have a matcher for 'exists'
        it { should_not be_file }
        it { should_not be_directory }
      end
    end

    context 'should succeed' do
      # XXX the core puppet file type will replace a symlink with a plain file
      # when using ensure => present and source => ... but it will not when using
      # ensure => present and content => ...; this is somewhat confusing behavior
      before(:all) do
        pp = <<-EOS
          file { '#{basedir}':
            ensure => directory,
          }
          file { '#{basedir}/file':
            ensure => link,
            target => '#{basedir}/dangling',
          }
        EOS
        apply_manifest(pp)
      end

      pp = <<-EOS
        concat { '#{basedir}/file':
          replace => true,
        }

        concat::fragment { '1':
          target  => '#{basedir}/file',
          content => '1',
        }

        concat::fragment { '2':
          target  => '#{basedir}/file',
          content => '2',
        }
      EOS

      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{basedir}/file") do
        it { should be_file }
        it { should contain '1' }
        it { should contain '2' }
      end
    end
  end # symlink

  context 'directory' do
    context 'should not succeed' do
      before(:all) do
        pp = <<-EOS
          file { '#{basedir}':
            ensure => directory,
          }
          file { '#{basedir}/file':
            ensure => directory,
          }
        EOS
        apply_manifest(pp)
      end
      pp = <<-EOS
        concat { '#{basedir}/file': }

        concat::fragment { '1':
          target  => '#{basedir}/file',
          content => '1',
        }

        concat::fragment { '2':
          target  => '#{basedir}/file',
          content => '2',
        }
      EOS

      it 'applies the manifest twice with stderr for changing to file' do
        expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/change from directory to file failed/)
        expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/change from directory to file failed/)
      end

      describe file("#{basedir}/file") do
        it { should be_directory }
      end
    end

    # XXX concat's force param currently enables the creation of empty files
    # when there are no fragments, and the replace param will only replace
    # files and symlinks, not directories.  The semantics either need to be
    # changed, extended, or a new param introduced to control directory
    # replacement.
    context 'should succeed', :pending => 'not yet implemented' do
      pp = <<-EOS
        concat { '#{basedir}/file':
          force => true,
        }

        concat::fragment { '1':
          target  => '#{basedir}/file',
          content => '1',
        }

        concat::fragment { '2':
          target  => '#{basedir}/file',
          content => '2',
        }
      EOS

      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{basedir}/file") do
        it { should be_file }
        it { should contain '1' }
      end
    end
  end # directory
end
