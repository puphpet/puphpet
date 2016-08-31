require 'spec_helper'

describe 'nginx::resource::geo' do
  let :title do
    'client_network'
  end

  let :default_params do
    {
      :default  => 'extra',
      :networks => {
        '172.16.0.0/12'  => 'intra',
        '192.168.0.0/16' => 'intra',
        '10.0.0.0/8'     => 'intra',
      },
      :proxies => [ '1.2.3.4', '4.3.2.1' ]
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

      it { should contain_file("/etc/nginx/conf.d/#{title}-geo.conf").with(
        {
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'ensure'  => 'file',
          'content' => /geo \$#{title}/,
        }
      )}
    end

    describe "geo.conf template content" do
      [
        {
          :title => 'should set address',
          :attr  => 'address',
          :value => '$remote_addr',
          :match => 'geo $remote_addr $client_network {'
        },
        {
          :title => 'should set ranges',
          :attr  => 'ranges',
          :value => true,
          :match => '  ranges;'
        },
        {
          :title => 'should set default',
          :attr  => 'default',
          :value => 'extra',
          :match => [ '  default extra;' ],
        },
        {
          :title => 'should contain ordered network directives',
          :attr  => 'networks',
          :value => {
            '192.168.0.0/16' => 'intra',
            '172.16.0.0/12'  => 'intra',
            '10.0.0.0/8'     => 'intra',
          },
          :match => [
            '  10.0.0.0/8 intra;',
            '  172.16.0.0/12 intra;',
            '  192.168.0.0/16 intra;',
          ],
        },
        {
          :title => 'should set multiple proxies',
          :attr  => 'proxies',
          :value => [ '1.2.3.4', '4.3.2.1' ],
          :match => [
            '  proxy 1.2.3.4;',
            '  proxy 4.3.2.1;'
          ]
        },
        {
          :title => 'should set proxy_recursive',
          :attr  => 'proxy_recursive',
          :value => true,
          :match => '  proxy_recursive;'
        },
        {
          :title => 'should set delete',
          :attr  => 'delete',
          :value => '192.168.0.0/16',
          :match => '  delete 192.168.0.0/16;'
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_file("/etc/nginx/conf.d/#{title}-geo.conf").with_mode('0644') }
          it param[:title] do
            verify_contents(subject, "/etc/nginx/conf.d/#{title}-geo.conf", Array(param[:match]))
            Array(param[:notmatch]).each do |item|
              should contain_file("/etc/nginx/conf.d/#{title}-geo.conf").without_content(item)
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

        it { should contain_file("/etc/nginx/conf.d/#{title}-geo.conf").with_ensure('absent') }
      end
    end
  end
end
