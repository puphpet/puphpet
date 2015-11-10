require 'spec_helper'

describe 'nginx::resource::map' do
  let :title do
    'backend_pool'
  end

  let :default_params do
    {
      :string   => '$uri',
      :default  => 'pool_a',
      :mappings => {
        'foo' => 'pool_b',
        'bar' => 'pool_c',
        'baz' => 'pool_d',
      },
    }
  end

  let :facts do
    {
      :osfamily        => 'RedHat',
      :operatingsystem => 'CentOS',
    }
  end

  let :pre_condition do
    [
      'include ::nginx::params',
      'include ::nginx::config',
    ]
  end

  describe 'os-independent items' do
    describe 'basic assumptions' do
      let :params do default_params end

      it { should contain_file("/etc/nginx/conf.d/#{title}-map.conf").with(
        {
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'ensure'  => 'file',
          'content' => /map \$uri \$#{title}/,
        }
      )}
    end

    describe "map.conf template content" do
      [
        {
          :title => 'should set hostnames',
          :attr  => 'hostnames',
          :value => true,
          :match => '  hostnames;'
        },
        {
          :title => 'should set default',
          :attr  => 'default',
          :value => 'pool_a',
          :match => [ '  default pool_a;' ],
        },
        {
          :title => 'should contain ordered mappings',
          :attr  => 'mappings',
          :value => {
            'foo' => 'pool_b',
            'bar' => 'pool_c',
            'baz' => 'pool_d',
          },
          :match => [
            '  bar pool_c;',
            '  baz pool_d;',
            '  foo pool_b;',
          ],
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_file("/etc/nginx/conf.d/#{title}-map.conf").with_mode('0644') }
          it param[:title] do
            verify_contents(subject, "/etc/nginx/conf.d/#{title}-map.conf", Array(param[:match]))
            Array(param[:notmatch]).each do |item|
              should contain_file("/etc/nginx/conf.d/#{title}-map.conf").without_content(item)
            end
          end
        end
      end

      context 'when ensure => absent' do
        let :params do default_params.merge(
          {
            :ensure => 'absent'
          }
        ) end

        it { should contain_file("/etc/nginx/conf.d/#{title}-map.conf").with_ensure('absent') }
      end
    end
  end
end
