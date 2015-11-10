require 'spec_helper'

# This is a reduced version of ruby_spec.rb just to ensure we can subclass as
# documented
$: << 'spec/fixtures/modules/inherit_ini_setting/lib'
provider_class = Puppet::Type.type(:inherit_ini_setting).provider(:ini_setting)
describe provider_class do
  include PuppetlabsSpec::Files

  let(:tmpfile) { tmpfilename('inherit_ini_setting_test') }

  def validate_file(expected_content,tmpfile = tmpfile)
    File.read(tmpfile).should == expected_content
  end


  before :each do
    File.open(tmpfile, 'w') do |fh|
      fh.write(orig_content)
    end
  end

  context 'when calling instances' do
    let(:orig_content) { '' }

    it 'should parse nothing when the file is empty' do
      provider_class.stubs(:file_path).returns(tmpfile)
      provider_class.instances.should == []
    end

    context 'when the file has contents' do
      let(:orig_content) {
        <<-EOS
# A comment
red = blue
green = purple
        EOS
      }

      it 'should parse the results' do
        provider_class.stubs(:file_path).returns(tmpfile)
        instances = provider_class.instances
        instances.size.should == 2
        # inherited version of namevar flattens the names
        names = instances.map do |instance|
          instance.instance_variable_get(:@property_hash)[:name]
        end
        names.sort.should == [ 'green', 'red' ]
      end
    end
  end

  context 'when ensuring that a setting is present' do
    let(:orig_content) { '' }

    it 'should add a value to the file' do
      provider_class.stubs(:file_path).returns(tmpfile)
      resource = Puppet::Type::Inherit_ini_setting.new({
        :setting => 'set_this',
        :value   => 'to_that',
      })
      provider = described_class.new(resource)
      provider.create
      validate_file("set_this=to_that\n")
    end
  end
end
