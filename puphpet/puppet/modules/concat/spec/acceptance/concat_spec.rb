require 'spec_helper_acceptance'

case fact('osfamily')
when 'AIX'
  username   = 'root'
  groupname  = 'system'
  scriptname = 'concatfragments.sh'
  vardir     = default['puppetvardir']
when 'Darwin'
  username   = 'root'
  groupname  = 'wheel'
  scriptname = 'concatfragments.sh'
  vardir     = default['puppetvardir']
when 'windows'
  username   = 'Administrator'
  groupname  = 'Administrators'
  scriptname = 'concatfragments.rb'
  result     = on default, "echo #{default['puppetvardir']}"
  vardir     = result.raw_output.chomp
when 'Solaris'
  username   = 'root'
  groupname  = 'root'
  scriptname = 'concatfragments.rb'
  vardir     = default['puppetvardir']
else
  username   = 'root'
  groupname  = 'root'
  scriptname = 'concatfragments.sh'
  vardir     = default['puppetvardir']
end

describe 'basic concat test' do
  basedir = default.tmpdir('concat')
  safe_basedir = basedir.gsub(/[\/:]/,'_')

  shared_examples 'successfully_applied' do |pp|
    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{vardir}/concat") do
      it { should be_directory }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 755
      }
    end
     describe file("#{vardir}/concat/bin") do
      it { should be_directory }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 755
      }
    end
    describe file("#{vardir}/concat/bin/#{scriptname}") do
      it { should be_file }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 755
      }
    end
    describe file("#{vardir}/concat/#{safe_basedir}_file") do
      it { should be_directory }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 750
      }
    end
    describe file("#{vardir}/concat/#{safe_basedir}_file/fragments") do
      it { should be_directory }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 750
      }
    end
    describe file("#{vardir}/concat/#{safe_basedir}_file/fragments.concat") do
      it { should be_file }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 640
      }
    end
    describe file("#{vardir}/concat/#{safe_basedir}_file/fragments.concat.out") do
      it { should be_file }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 640
      }
    end
  end

  context 'owner/group root' do
    before(:all) do
      pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
      EOS
      apply_manifest(pp)
    end
    pp = <<-EOS
      concat { '#{basedir}/file':
        owner => '#{username}',
        group => '#{groupname}',
        mode  => '0644',
      }

      concat::fragment { '1':
        target  => '#{basedir}/file',
        content => '1',
        order   => '01',
      }

      concat::fragment { '2':
        target  => '#{basedir}/file',
        content => '2',
        order   => '02',
      }
    EOS

    it_behaves_like 'successfully_applied', pp

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 644
      }
      it { should contain '1' }
      it { should contain '2' }
    end
    describe file("#{vardir}/concat/#{safe_basedir}_file/fragments/01_1") do
      it { should be_file }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 640
      }
    end
    describe file("#{vardir}/concat/#{safe_basedir}_file/fragments/02_2") do
      it { should be_file }
      it { should be_owned_by username }
      it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
        should be_mode 640
      }
    end
  end

  context 'ensure' do
    context 'works when set to present with path set' do
      before(:all) do
        pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
        EOS
        apply_manifest(pp)
      end
      pp="
        concat { 'file':
          ensure => present,
          path   => '#{basedir}/file',
          mode   => '0644',
        }
        concat::fragment { '1':
          target  => 'file',
          content => '1',
          order   => '01',
        }
      "

      it_behaves_like 'successfully_applied', pp

      describe file("#{basedir}/file") do
        it { should be_file }
        it("should be mode", :unless => (fact('osfamily') == 'AIX')) {
          should be_mode 644
        }
        it { should contain '1' }
      end
    end
    context 'works when set to absent with path set' do
      before(:all) do
        pp = <<-EOS
        file { '#{basedir}':
          ensure => directory,
        }
        EOS
        apply_manifest(pp)
      end
      pp="
        concat { 'file':
          ensure => absent,
          path   => '#{basedir}/file',
          mode   => '0644',
        }
        concat::fragment { '1':
          target  => 'file',
          content => '1',
          order   => '01',
        }
      "

      it 'applies the manifest twice with no stderr' do
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe file("#{basedir}/file") do
        it { should_not be_file }
      end
    end
  end
end
