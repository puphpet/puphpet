require 'spec_helper'

describe 'java', :type => :class do

  context 'select openjdk for Centos 5.8' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '5.8'} }
    it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }
  end

  context 'select openjdk for Centos 6.3' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '6.3'} }
    it { should contain_package('java').with_name('java-1.7.0-openjdk-devel') }
  end

  context 'select openjdk for Centos 6.2' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '6.2'} }
    it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }
    it { should_not contain_exec('update-java-alternatives') }
  end

  context 'select Oracle JRE with alternatives for Centos 6.3' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '6.3'} }
    let(:params) { { 'package' => 'jre', 'java_alternative' => '/usr/bin/java', 'java_alternative_path' => '/usr/java/jre1.7.0_67/bin/java'} }
    it { should contain_package('java').with_name('jre') }
    it { should contain_exec('create-java-alternatives').with_command('alternatives --install /usr/bin/java java /usr/java/jre1.7.0_67/bin/java 20000') }
    it { should contain_exec('update-java-alternatives').with_command('alternatives --set java /usr/java/jre1.7.0_67/bin/java') }
  end

  context 'select openjdk for Fedora' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Fedora'} }
    it { should contain_package('java').with_name('java-1.7.0-openjdk-devel') }
  end

  context 'select passed value for Fedora' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Fedora'} }
    let(:params) { { 'distribution' => 'jre' } }
    it { should contain_package('java').with_name('java-1.7.0-openjdk') }
  end

  context 'select passed value for Centos 5.3' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '5.3'} }
    let(:params) { { 'package' => 'jdk' } }
    it { should contain_package('java').with_name('jdk') }
    it { should_not contain_exec('update-java-alternatives') }
  end

  context 'select default for Centos 5.3' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Centos', :operatingsystemrelease => '5.3'} }
    it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }
    it { should_not contain_exec('update-java-alternatives') }
  end

  context 'select default for Debian Wheezy' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'wheezy', :operatingsystemrelease => '7.1', :architecture => 'amd64',} }
    it { should contain_package('java').with_name('openjdk-7-jdk') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set java-1.7.0-openjdk-amd64 --jre') }
  end

  context 'select Oracle JRE for Debian Wheezy' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'wheezy', :operatingsystemrelease => '7.1', :architecture => 'amd64',} }
    let(:params) { { 'distribution' => 'oracle-jre' } }
    it { should contain_package('java').with_name('oracle-j2re1.7') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set j2re1.7-oracle --jre') }
  end

  context 'select OpenJDK JRE for Debian Wheezy' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'wheezy', :operatingsystemrelease => '7.1', :architecture => 'amd64',} }
    let(:params) { { 'distribution' => 'jre' } }
    it { should contain_package('java').with_name('openjdk-7-jre-headless') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set java-1.7.0-openjdk-amd64 --jre-headless') }
  end

  context 'select default for Debian Squeeze' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'squeeze', :operatingsystemrelease => '6.0.5', :architecture => 'amd64',} }
    it { should contain_package('java').with_name('openjdk-6-jdk') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set java-6-openjdk-amd64 --jre') }
  end

  context 'select Oracle JRE for Debian Squeeze' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'squeeze', :operatingsystemrelease => '6.0.5', :architecture => 'amd64',} }
    let(:params) { { 'distribution' => 'sun-jre', } }
    it { should contain_package('java').with_name('sun-java6-jre') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set java-6-sun --jre') }
  end

  context 'select OpenJDK JRE for Debian Squeeze' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'squeeze', :operatingsystemrelease => '6.0.5', :architecture => 'amd64',} }
    let(:params) { { 'distribution' => 'jre', } }
    it { should contain_package('java').with_name('openjdk-6-jre-headless') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set java-6-openjdk-amd64 --jre-headless') }
  end

  context 'select random alternative for Debian Wheezy' do
    let(:facts) { {:osfamily => 'Debian', :operatingsystem => 'Debian', :lsbdistcodename => 'wheezy', :operatingsystemrelease => '7.1', :architecture => 'amd64',} }
    let(:params) { { 'java_alternative' => 'bananafish' } }
    it { should contain_package('java').with_name('openjdk-7-jdk') }
    it { should contain_exec('update-java-alternatives').with_command('update-java-alternatives --set bananafish --jre') }
  end

  context 'select openjdk for Amazon Linux' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Amazon', :operatingsystemrelease => '3.4.43-43.43.amzn1.x86_64'} }
    it { should contain_package('java').with_name('java-1.7.0-openjdk-devel') }
  end

  context 'select passed value for Amazon Linux' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Amazon', :operatingsystemrelease => '5.3.4.43-43.43.amzn1.x86_64'} }
    let(:params) { { 'distribution' => 'jre' } }
    it { should contain_package('java').with_name('java-1.7.0-openjdk') }
  end

  context 'select openjdk for Oracle Linux' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'OracleLinux', :operatingsystemrelease => '6.4'} }
    it { should contain_package('java').with_name('java-1.7.0-openjdk-devel') }
  end

  context 'select openjdk for Oracle Linux 6.2' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'OracleLinux', :operatingsystemrelease => '6.2'} }
    it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }
  end

  context 'select passed value for Oracle Linux' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'OracleLinux', :operatingsystemrelease => '6.3'} }
    let(:params) { { 'distribution' => 'jre' } }
    it { should contain_package('java').with_name('java-1.7.0-openjdk') }
  end

  context 'select passed value for Scientific Linux' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystem => 'Scientific', :operatingsystemrelease => '6.4'} }
    let(:params) { { 'distribution' => 'jre' } }
    it { should contain_package('java').with_name('java-1.7.0-openjdk') }
  end

  context 'select default for OpenSUSE 12.3' do
    let(:facts) { {:osfamily => 'Suse', :operatingsystem => 'OpenSUSE', :operatingsystemrelease => '12.3'}}
    it { should contain_package('java').with_name('java-1_7_0-openjdk-devel')}
  end

  describe 'incompatible OSs' do
    [
      {
        # C14706
        :osfamily               => 'windows',
        :operatingsystem        => 'windows',
        :operatingsystemrelease => '8.1',
      },
      {
        # C14707
        :osfamily               => 'Darwin',
        :operatingsystem        => 'Darwin',
        :operatingsystemrelease => '13.3.0',
      },
      {
        # C14708
        :osfamily               => 'AIX',
        :operatingsystem        => 'AIX',
        :operatingsystemrelease => '7100-02-00-000',
      },
      {
        # C14708
        :osfamily               => 'AIX',
        :operatingsystem        => 'AIX',
        :operatingsystemrelease => '6100-07-04-1216',
      },
      {
        # C14708
        :osfamily               => 'AIX',
        :operatingsystem        => 'AIX',
        :operatingsystemrelease => '5300-12-01-1016',
      },
    ].each do |facts|
      let(:facts) { facts }
      it "should fail on #{facts[:operatingsystem]} #{facts[:operatingsystemrelease]}" do
        expect { subject }.to raise_error Puppet::Error, /unsupported platform/
      end
    end
  end
end
