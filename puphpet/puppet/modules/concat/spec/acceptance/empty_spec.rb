require 'spec_helper_acceptance'

describe 'concat force empty parameter' do
  basedir = default.tmpdir('concat')
  context 'should run successfully' do
    pp = <<-EOS
      concat { '#{basedir}/file':
        mode  => '0644',
        force => true,
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should_not contain '1\n2' }
    end
  end
end
