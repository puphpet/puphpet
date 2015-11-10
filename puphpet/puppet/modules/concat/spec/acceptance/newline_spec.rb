require 'spec_helper_acceptance'

describe 'concat ensure_newline parameter' do
  basedir = default.tmpdir('concat')
  context '=> false' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory
        }
      EOS

      apply_manifest(pp)
    end
    pp = <<-EOS
      concat { '#{basedir}/file':
        ensure_newline => false,
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
      it { should contain '12' }
    end
  end

  context '=> true' do
    pp = <<-EOS
      concat { '#{basedir}/file':
        ensure_newline => true,
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
      apply_manifest(pp, :catch_changes  => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it("should contain 1\n2\n", :unless => (fact('osfamily') == 'Solaris')) {
        should contain "1\n2\n"
      }
    end
  end
end
