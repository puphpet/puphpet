require 'spec_helper_acceptance'

describe 'composer::project class' do
  describe 'running puppet code' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
        include composer
        composer::project {'silex':
          project_name => 'fabpot/silex-skeleton',
          target_dir   => '/tmp/silex',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe file('/tmp/silex/composer.json') do
    it { should be_file }
  end
end
