require 'spec_helper'
require 'digest/md5'

describe 'nginx::resource::location' do
  let :title do
    'rspec-test'
  end
  let :facts do
    {
      :osfamily        => 'Debian',
      :operatingsystem => 'debian',
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
      let :params do {
        :www_root => "/var/www/rspec",
        :vhost    => 'vhost1',
      } end

      it { should contain_class("nginx::params") }
      it { should contain_class("nginx::config") }
      it { should contain_concat__fragment("f25e14942fb58942ee13b1465a4e1719").with_content(/location rspec-test/) }
      it { should_not contain_file('/etc/nginx/fastcgi_params') }
      it { should_not contain_concat__fragment("vhost1-800-rspec-test-ssl") }
      it { should_not contain_file("/etc/nginx/rspec-test_htpasswd") }
    end

    describe "vhost/location_header template content" do
      [
        {
          :title => 'should set the location',
          :attr  => 'location',
          :value => 'my_location',
          :match => '  location my_location {',
        },
        {
          :title    => 'should not set internal',
          :attr     => 'internal',
          :value    => false,
          :notmatch => /internal;/
        },
        {
          :title => 'should set internal',
          :attr  => 'internal',
          :value => true,
          :match => '    internal;'
        },
        {
          :title => 'should set location_allow',
          :attr  => 'location_allow',
          :value => %w( 127.0.0.1 10.0.0.1 ),
          :match => [
            '    allow 127.0.0.1;',
            '    allow 10.0.0.1;',
          ],
        },
        {
          :title => 'should set location_deny',
          :attr  => 'location_deny',
          :value => %w( 127.0.0.1 10.0.0.1 ),
          :match => [
            '    deny 127.0.0.1;',
            '    deny 10.0.0.1;',
          ],
        },
        {
          :title => 'should contain ordered prepended directives',
          :attr  => 'location_cfg_prepend',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            '    test1 test value 1;',
            '    test2 test value 2a;',
            '    test2 test value 2b;',
            '    test3 subtest1 "sub test value1a";',
            '    test3 subtest1 "sub test value1b";',
            '    test3 subtest2 "sub test value2";',
          ],
        },
        {
          :title => 'should contain custom prepended directives',
          :attr  => 'location_custom_cfg_prepend',
          :value => { 'test1' => 'bar', 'test2' => ['foobar', 'barbaz'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            /^[ ]+test1\s+bar/,
            /^[ ]+test2\s+foobar/,
            /^[ ]+test2\s+barbaz/,
            /^[ ]+test3\s+subtest1 "sub test value1a"/,
            /^[ ]+test3\s+subtest1 "sub test value1b"/,
            /^[ ]+test3\s+subtest2 "sub test value2"/,
          ],
        },
        {
          :title => 'should contain raw_prepend directives',
          :attr  => 'raw_prepend',
          :value => [
            'if (a) {',
            '  b;',
            '}'
          ],
          :match => /^\s+if \(a\) {\n\s++b;\n\s+\}/,
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :proxy => 'proxy_value', :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }

          it param[:title] do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| should contain_concat__fragment(fragment).with_content(item) }
            else
              lines = subject.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              (lines & matches).should == matches
            end

            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).without_content(item)
            end
          end
        end
      end
    end

    describe "vhost/location_footer template content" do
      [
        {
          :title => 'should contain ordered appended directives',
          :attr  => 'location_cfg_append',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            '    test1 test value 1;',
            '    test2 test value 2a;',
            '    test2 test value 2b;',
            '    test3 subtest1 "sub test value1a";',
            '    test3 subtest1 "sub test value1b";',
            '    test3 subtest2 "sub test value2";',
          ],
        },
        {
          :title => 'should contain custom appended directives',
          :attr  => 'location_custom_cfg_append',
          :value => { 'test1' => 'bar', 'test2' => ['foobar', 'barbaz'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            /^[ ]+test1\s+bar/,
            /^[ ]+test2\s+foobar/,
            /^[ ]+test2\s+barbaz/,
            /^[ ]+test3\s+subtest1 "sub test value1a"/,
            /^[ ]+test3\s+subtest1 "sub test value1b"/,
            /^[ ]+test3\s+subtest2 "sub test value2"/,
          ],
        },
        {
          :title => 'should contain raw_append directives',
          :attr  => 'raw_append',
          :value => [
            'if (a) {',
            '  b;',
            '}'
          ],
          :match => /^\s+if \(a\) {\n\s++b;\n\s+\}/,
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :proxy => 'proxy_value', :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }

          it param[:title] do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| should contain_concat__fragment(fragment).with_content(item) }
            else
              lines = subject.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              (lines & matches).should == matches
            end

            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).without_content(item)
            end
          end

          it "should end with a closing brace" do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            content = subject.resource('concat::fragment', fragment).send(:parameters)[:content]
            (content.split("\n").reject {|l| l =~ /^(\s*#|$)/ }.last).strip.should == '}'
          end
        end
      end
    end

    describe "vhost_location_alias template content" do
      let :default_params do
        { :location => 'location', :vhost => 'vhost1', :location_alias => 'value' }
      end

      context "when location_alias is 'value'" do
        let :params do default_params end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")) }
        it "should set alias" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")).
                  with_content(/^[ ]+alias\s+value;/)
        end
      end

      context "when autoindex is 'on'" do
        let :params do default_params.merge({ :autoindex => 'on' }) end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")) }
        it "should set autoindex" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")).
                  with_content(/^[ ]+autoindex\s+on;/)
        end
      end

      context "when autoindex is not set" do
        let :params do default_params end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")) }
        it "should not set autoindex" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")).
                  without_content(/^[ ]+autoindex[^;]+;/)
        end
      end
    end

    describe "vhost_location_directory template content" do
      let :default_params do
        {
          :location => 'location',
          :www_root => '/var/www/root',
          :vhost    => 'vhost1'
        }
      end

      [
        {
          :title => 'should set www_root',
          :attr  => 'www_root',
          :value => '/',
          :match => '    root  /;'
        },
        {
          :title => 'should set try_file(s)',
          :attr  => 'try_files',
          :value => ['name1','name2'],
          :match => '    try_files name1 name2;',
        },
        {
          :title => 'should set index_file(s)',
          :attr  => 'index_files',
          :value => ['name1','name2'],
          :match => '    index  name1 name2;',
        },
        {
          :title => 'should contain rewrite rules',
          :attr  => 'rewrite_rules',
          :value => [
            '^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last',
            '^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  last',
            '^/users/(.*)$ /show?user=$1? last',
          ],
          :match => [
            '    rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last;',
            '    rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  last;',
            '    rewrite ^/users/(.*)$ /show?user=$1? last;',
          ],
        },
        {
          :title    => 'should not set rewrite_rules',
          :attr     => 'rewrite_rules',
          :value    => [],
          :notmatch => /rewrite/
        },
        {
          :title => 'should set auth_basic',
          :attr  => 'auth_basic',
          :value => 'value',
          :match => '    auth_basic           "value";',
        },
        {
          :title => 'should set auth_basic_user_file',
          :attr  => 'auth_basic_user_file',
          :value => 'value',
          :match => '    auth_basic_user_file value;',
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }
          it param[:title] do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| should contain_concat__fragment(fragment).with_content(item) }
            else
              lines = subject.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              (lines & matches).should == matches
            end

            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).without_content(item)
            end
          end
        end
      end

      context "when autoindex is 'on'" do
        let :params do default_params.merge({ :autoindex => 'on' }) end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")) }
        it "should set autoindex" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")).
                  with_content(/^[ ]+autoindex\s+on;/)
        end
      end

      context "when autoindex is not set" do
        let :params do default_params end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")) }
        it "should not set autoindex" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")).
                  without_content(/^[ ]+autoindex[^;]+;/)
        end
      end
    end

    describe "vhost_location_empty template content" do
      [
        {
          :title => 'should contain ordered config directives',
          :attr  => 'location_custom_cfg',
          :value => { 'test1' => ['test value 1a', 'test value 1b'], 'test2' => 'test value 2', 'allow' => 'test value 3',
                      'test4' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            '    allow test value 3;',
            '    test1 test value 1a;',
            '    test1 test value 1b;',
            '    test2 test value 2;',
            '    test4 subtest1 "sub test value1a";',
            '    test4 subtest1 "sub test value1b";',
            '    test4 subtest2 "sub test value2";',
          ],
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :location_custom_cfg => {'test1'=>'value1'}, :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }
          it param[:title] do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| should contain_concat__fragment(fragment).with_content(item) }
            else
              lines = subject.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              (lines & matches).should == matches
            end

            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).without_content(item)
            end
          end
        end
      end
    end

    describe "vhost_location_fastcgi template content" do
      let :default_params do
        {
          :location => 'location',
          :fastcgi  => 'localhost:9000',
          :vhost    => 'vhost1'
        }
      end

      [
        {
          :title => 'should set www_root',
          :attr  => 'www_root',
          :value => '/',
          :match => '    root  /;'
        },
        {
          :title => 'should set fastcgi_split_path',
          :attr  => 'fastcgi_split_path',
          :value => 'value',
          :match => '    fastcgi_split_path_info value;'
        },
        {
          :title => 'should set try_file(s)',
          :attr  => 'try_files',
          :value => ['name1','name2'],
          :match => '    try_files name1 name2;',
        },
        {
          :title => 'should set fastcgi_params',
          :attr  => 'fastcgi_params',
          :value => 'value',
          :match => /^[ ]+include\s+value;/
        },
        {
          :title => 'should set fastcgi_pass',
          :attr  => 'fastcgi',
          :value => 'value',
          :match => '    fastcgi_pass value;'
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }
          it param[:title] do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| should contain_concat__fragment(fragment).with_content(item) }
            else
              lines = subject.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              (lines & matches).should == matches
            end

            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).without_content(item)
            end
          end
        end
      end

      context "when fastcgi_script is 'value'" do
        let :params do default_params.merge({ :fastcgi_script => 'value' }) end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }
        it "should set fastcgi_script" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).
                  with_content(%r|^[ ]+fastcgi_param\s+SCRIPT_FILENAME\s+value;|)
        end
      end

      context "when fastcgi_script is not set" do
        let :params do default_params end
        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }
        it "should not set fastcgi_script" do
          should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).
                  without_content(/^[ ]+fastcgi_param\s+SCRIPT_FILENAME\s+.+?;/)
        end
      end
    end

    describe "vhost_location_proxy template content" do
      [
        {
          :title => 'should set proxy_cache',
          :attr  => 'proxy_cache',
          :value => 'value',
          :match => /^[ ]+proxy_cache\s+value;/,
        },
        {
          :title    => 'should not set proxy_cache',
          :attr     => 'proxy_cache',
          :value    => false,
          :notmatch => /proxy_cache\b/
        },
        {
          :title => 'should set proxy_pass',
          :attr  => 'proxy',
          :value => 'value',
          :match => /^[ ]+proxy_pass\s+value;/,
        },
        {
          :title => 'should set proxy_read_timeout',
          :attr  => 'proxy_read_timeout',
          :value => 'value',
          :match => '    proxy_read_timeout  value;',
        },
        {
          :title => 'should set proxy_connect_timeout',
          :attr  => 'proxy_connect_timeout',
          :value => 'value',
          :match => '    proxy_connect_timeout  value;',
        },
        {
          :title => 'should set proxy_read_timeout',
          :attr  => 'proxy_read_timeout',
          :value => 'value',
          :match => '    proxy_read_timeout  value;',
        },
        {
          :title => 'should set proxy headers',
          :attr  => 'proxy_set_header',
          :value => [ 'X-TestHeader1 value1', 'X-TestHeader2 value2' ],
          :match => [
            /^[ ]+proxy_set_header\s+X-TestHeader1 value1;/,
            /^[ ]+proxy_set_header\s+X-TestHeader2 value2;/,
          ]
        },
        {
          :title => 'should set proxy_method',
          :attr  => 'proxy_method',
          :value => 'value',
          :match => '    proxy_method        value;',
        },
        {
          :title => 'should set proxy_set_body',
          :attr  => 'proxy_set_body',
          :value => 'value',
          :match => '    proxy_set_body      value;',
        },
        {
          :title => 'should contain rewrite rules',
          :attr  => 'rewrite_rules',
          :value => [
            '^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last',
            '^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  last',
            '^/users/(.*)$ /show?user=$1? last',
          ],
          :match => [
            '    rewrite ^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last;',
            '    rewrite ^(/download/.*)/audio/(.*)\..*$ $1/mp3/$2.ra  last;',
            '    rewrite ^/users/(.*)$ /show?user=$1? last;',
          ],
        },
        {
          :title    => 'should not set rewrite_rules',
          :attr     => 'rewrite_rules',
          :value    => [],
          :notmatch => /rewrite/
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :proxy => 'proxy_value', :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")) }
          it param[:title] do
            fragment = Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| should contain_concat__fragment(fragment).with_content(item) }
            else
              lines = subject.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              (lines & matches).should == matches
            end

            Array(param[:notmatch]).each do |item|
              should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).without_content(item)
            end
          end
        end
      end

      context "when proxy_cache_valid is 10m" do
        let :params do {
          :location => 'location',
          :proxy => 'proxy_value',
          :vhost => 'vhost1',
          :proxy_cache => 'true',
          :proxy_cache_valid => '10m',
        } end

        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-location")).with_content(/proxy_cache_valid   10m;/) }
      end
    end

    describe "vhost_location_stub_status template content" do
      let :params do { :location => 'location', :stub_status => true, :vhost => 'vhost1' }  end
      it do
        should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-#{params[:location]}")).
                 with_content(/stub_status\s+on/)
      end
    end

    context 'attribute resources' do
      context 'when fastcgi => "localhost:9000"' do
        let :params do { :fastcgi => 'localhost:9000', :vhost => 'vhost1' } end

        it { should contain_file('/etc/nginx/fastcgi_params').with_mode('0770') }
      end

      context 'when ssl_only => true' do
        let :params do { :ssl_only => true, :vhost => 'vhost1', :www_root => '/', } end
        it { should_not contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-rspec-test")) }
      end

      context 'when ssl_only => false' do
        let :params do { :ssl_only => false, :vhost => 'vhost1', :www_root => '/', } end

        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-500-rspec-test")) }
      end

      context 'when ssl => true' do
        let :params do { :ssl => true, :vhost => 'vhost1', :www_root => '/', } end

        it { should contain_concat__fragment(Digest::MD5.hexdigest("vhost1-800-rspec-test-ssl")) }
      end

      context 'when ssl => false' do
        let :params do { :ssl => false, :vhost => 'vhost1', :www_root => '/', } end

        it { should_not contain_concat__fragment(Digest::MD5.hexdigest("vhost1-800-rspec-test-ssl")) }
      end

      context 'when auth_basic_user_file => true' do
        let :params do { :auth_basic_user_file => '/path/to/file', :vhost => 'vhost1', :www_root => '/', } end

        it { should contain_file("/etc/nginx/rspec-test_htpasswd") }
      end

      context 'when ensure => absent' do
        let :params do {
          :www_root             => '/',
          :vhost                => 'vhost1',
          :ensure               => 'absent',
          :ssl                  => true,
          :auth_basic_user_file => '/path/to/file',
        } end

        it { should contain_file("/etc/nginx/rspec-test_htpasswd").with_ensure('absent') }
      end

      context "vhost missing" do
        let :params do {
          :www_root => '/',
        } end

        it { expect { should contain_class('nginx::resource::location') }.to raise_error(Puppet::Error, /Cannot create a location reference without attaching to a virtual host/) }
      end

      context "location type missing" do
        let :params do {
          :vhost => 'vhost1',
        } end

        it { expect { should contain_class('nginx::resource::location') }.to raise_error(Puppet::Error, /Cannot create a location reference without a www_root, proxy, location_alias, fastcgi, stub_status, or location_custom_cfg defined/) }
      end

      context "www_root and proxy are set" do
        let :params do {
          :vhost    => 'vhost1',
          :www_root => '/',
          :proxy    => 'http://localhost:8000/uri/',
        } end

        it { expect { should contain_class('nginx::resource::location') }.to raise_error(Puppet::Error, /Cannot define both directory and proxy in a virtual host/) }
      end

      context 'when vhost name is sanitized' do
        let :title do 'www.rspec-location.com' end
        let :params do {
          :vhost => 'www rspec-vhost com',
          :www_root => '/',
          :ssl => true,
        } end

        it { should contain_concat__fragment(Digest::MD5.hexdigest("www_rspec-vhost_com-500-www.rspec-location.com")).with_target('/etc/nginx/sites-available/www_rspec-vhost_com.conf') }
        it { should contain_concat__fragment(Digest::MD5.hexdigest("www_rspec-vhost_com-800-www.rspec-location.com-ssl")).with_target('/etc/nginx/sites-available/www_rspec-vhost_com.conf') }
      end
    end
  end
end
