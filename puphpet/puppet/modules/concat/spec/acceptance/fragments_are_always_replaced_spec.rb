require 'spec_helper_acceptance'

describe 'concat::fragment replace' do
  basedir = default.tmpdir('concat')

  context 'should create fragment files' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
      EOS
      apply_manifest(pp)
    end

    pp1 = <<-EOS
      concat { '#{basedir}/foo': }

      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'caller has replace unset run 1',
      }
    EOS
    pp2 = <<-EOS
      concat { '#{basedir}/foo': }

      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'caller has replace unset run 2',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp1, :catch_failures => true)
      apply_manifest(pp1, :catch_changes => true)
      apply_manifest(pp2, :catch_failures => true)
      apply_manifest(pp2, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      it { should_not contain 'caller has replace unset run 1' }
      it { should contain 'caller has replace unset run 2' }
    end
  end # should create fragment files

  context 'should replace its own fragment files when caller has File { replace=>true } set' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
      EOS
      apply_manifest(pp)
    end

    pp1 = <<-EOS
      File { replace=>true }
      concat { '#{basedir}/foo': }

      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'caller has replace true set run 1',
      }
    EOS
    pp2 = <<-EOS
      File { replace=>true }
      concat { '#{basedir}/foo': }

      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'caller has replace true set run 2',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp1, :catch_failures => true)
      apply_manifest(pp1, :catch_changes => true)
      apply_manifest(pp2, :catch_failures => true)
      apply_manifest(pp2, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      it { should_not contain 'caller has replace true set run 1' }
      it { should contain 'caller has replace true set run 2' }
    end
  end # should replace its own fragment files when caller has File(replace=>true) set

  context 'should replace its own fragment files even when caller has File { replace=>false } set' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
      EOS
      apply_manifest(pp)
    end

    pp1 = <<-EOS
      File { replace=>false }
      concat { '#{basedir}/foo': }

      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'caller has replace false set run 1',
      }
    EOS
    pp2 = <<-EOS
      File { replace=>false }
      concat { '#{basedir}/foo': }

      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'caller has replace false set run 2',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp1, :catch_failures => true)
      apply_manifest(pp1, :catch_changes => true)
      apply_manifest(pp2, :catch_failures => true)
      apply_manifest(pp2, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      it { should_not contain 'caller has replace false set run 1' }
      it { should contain 'caller has replace false set run 2' }
    end
  end # should replace its own fragment files even when caller has File(replace=>false) set

end
