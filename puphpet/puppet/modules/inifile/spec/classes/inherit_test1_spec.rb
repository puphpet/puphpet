require 'spec_helper'
# We can't really test much here, apart from the type roundtrips though the
# parser OK.
describe 'inherit_test1' do
  it do
    should contain_inherit_ini_setting('valid_type').with({
      'value' => 'true'
    })
  end
end
