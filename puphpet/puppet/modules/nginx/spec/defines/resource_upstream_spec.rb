require 'spec_helper'

describe 'nginx::resource::upstream' do
  let :title do
    'upstream-test'
  end

  let :default_params do
    {
      :members => ['test'],
    }
  end

  let :pre_condition do
      [
      'include ::nginx::params',
      'include ::nginx::config',
      ]
  end

  let :default_facts do
    {
      :osfamily        => 'RedHat',
      :operatingsystem => 'CentOS',
      :concat_basedir  => '/var/lib/puppet/concat'
    }
  end

  let :pre_condition do
    [
      'include ::nginx::params',
      'include ::nginx::config',
    ]
  end

  describe 'os-independent items' do
    let :facts do default_facts end

    describe 'basic assumptions' do
      let :params do default_params end

      it { should contain_class("nginx::params") }
      it { should contain_class('concat::setup') }
      it { should contain_file("/etc/nginx/conf.d/#{title}-upstream.conf") }
      it { should contain_concat__fragment("#{title}_upstream_header").with_content(/upstream #{title}/) }

      it {
        should contain_concat__fragment("#{title}_upstream_header").with(
        {
          'target' => "/etc/nginx/conf.d/#{title}-upstream.conf",
          'order'  => 10,
        }
      )}

      it {
        should contain_concat__fragment("#{title}_upstream_members").with(
        {
          'target' => "/etc/nginx/conf.d/#{title}-upstream.conf",
          'order'  => 50,
        }
      )}

      it {
        should contain_concat__fragment("#{title}_upstream_footer").with(
        {
          'target' => "/etc/nginx/conf.d/#{title}-upstream.conf",
          'order'  => 90,
        }).with_content("}\n")
      }
    end

    describe "upstream.conf template content" do
      let :facts do default_facts end
      [
        {
          :title    => 'should contain ordered prepended directives',
          :attr     => 'upstream_cfg_prepend',
          :fragment => 'header',
          :value => {
            'test3' => 'test value 3',
            'test6' => {'subkey1' => ['subvalue1', 'subvalue2']},
            'test1' => 'test value 1',
            'test2' => 'test value 2',
            'test5' => {'subkey1' => 'subvalue1'},
            'test4' => ['test value 1', 'test value 2'],
          },
          :match => [
            '  test1 test value 1;',
            '  test2 test value 2;',
            '  test3 test value 3;',
            '  test4 test value 1;',
            '  test4 test value 2;',
            '  test5 subkey1 subvalue1;',
            '  test6 subkey1 subvalue1;',
            '  test6 subkey1 subvalue2;',
          ],
        },
        {
          :title    => 'should set server',
          :attr     => 'members',
          :fragment => 'members',
          :value    => %W( test3 test1 test2 ),
          :match    => [
            '  server     test3  fail_timeout=10s;',
            '  server     test1  fail_timeout=10s;',
            '  server     test2  fail_timeout=10s;',
          ],
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_file("/etc/nginx/conf.d/#{title}-upstream.conf").with_mode('0644') }
          it { should contain_concat__fragment("#{title}_upstream_#{param[:fragment]}") }
          it param[:title] do
            lines = subject.resource('concat::fragment', "#{title}_upstream_#{param[:fragment]}").send(:parameters)[:content].split("\n")
            (lines & Array(param[:match])).should == Array(param[:match])
            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment("#{title}_upstream_#{param[:fragment]}").without_content(item)
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

        it { should contain_file("/etc/nginx/conf.d/#{title}-upstream.conf").with_ensure('absent') }
      end
    end
  end
end
