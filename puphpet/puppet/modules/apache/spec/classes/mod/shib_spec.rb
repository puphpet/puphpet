describe 'apache::mod::shib', :type => :class do
  let :pre_condition do
    'include apache'
  end
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :fqdn                   => 'test.example.com',
        :is_pe                  => false,
      }
    end
    describe 'with no parameters' do
      it { should contain_apache__mod('shib2').with_id('mod_shib') }
    end
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :fqdn                   => 'test.example.com',
        :is_pe                  => false,
      }
    end
    describe 'with no parameters' do
      it { should contain_apache__mod('shib2').with_id('mod_shib') }
    end
  end
end
