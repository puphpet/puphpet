require 'spec_helper_acceptance'

describe 'concat backup parameter' do
  basedir = default.tmpdir('concat')
  context '=> puppet' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
        file { '#{basedir}/file':
          content => "old contents\n",
        }
      EOS
      apply_manifest(pp)
    end
    pp = <<-EOS
      concat { '#{basedir}/file':
        backup => 'puppet',
      }
      concat::fragment { 'new file':
        target  => '#{basedir}/file',
        content => 'new contents',
      }
    EOS

    it 'applies the manifest twice with "Filebucketed" stdout and no stderr' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Filebucketed #{basedir}\/file to puppet with sum 0140c31db86293a1a1e080ce9b91305f/) # sum is for file contents of 'old contents'
      end
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should contain 'new contents' }
    end
  end

  context '=> .backup' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
        file { '#{basedir}/file':
          content => "old contents\n",
        }
      EOS
      apply_manifest(pp)
    end
    pp = <<-EOS
      concat { '#{basedir}/file':
        backup => '.backup',
      }
      concat::fragment { 'new file':
        target  => '#{basedir}/file',
        content => 'new contents',
      }
    EOS

    # XXX Puppet doesn't mention anything about filebucketing with a given
    # extension like .backup
    it 'applies the manifest twice  no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should contain 'new contents' }
    end
    describe file("#{basedir}/file.backup") do
      it { should be_file }
      it { should contain 'old contents' }
    end
  end

  # XXX The backup parameter uses validate_string() and thus can't be the
  # boolean false value, but the string 'false' has the same effect in Puppet 3
  context "=> 'false'" do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
        file { '#{basedir}/file':
          content => "old contents\n",
        }
      EOS
      apply_manifest(pp)
    end
    pp = <<-EOS
      concat { '#{basedir}/file':
        backup => '.backup',
      }
      concat::fragment { 'new file':
        target  => '#{basedir}/file',
        content => 'new contents',
      }
    EOS

    it 'applies the manifest twice with no "Filebucketed" stdout and no stderr' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to_not match(/Filebucketed/)
      end
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should contain 'new contents' }
    end
  end
end
