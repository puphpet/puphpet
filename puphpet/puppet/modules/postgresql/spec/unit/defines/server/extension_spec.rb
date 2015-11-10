require 'spec_helper'

describe 'postgresql::server::extension', :type => :define do
  let :pre_condition do
    "class { 'postgresql::server': }
     postgresql::server::database { 'template_postgis':
       template   => 'template1',
     }"
  end

  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :concat_basedir => tmpfilename('postgis'),
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  let (:title) { 'postgis' }
  let (:params) { {
    :database => 'template_postgis',
  } }

  context "with mandatory arguments only" do
    it {
      is_expected.to contain_postgresql_psql('Add postgis extension to template_postgis').with({
        :db      => 'template_postgis',
        :command => 'CREATE EXTENSION postgis',
        :unless  => "SELECT t.count FROM (SELECT count(extname) FROM pg_extension WHERE extname = 'postgis') as t WHERE t.count = 1",
      }).that_requires('Postgresql::Server::Database[template_postgis]')
    }
  end

  context "when setting package name" do
    let (:params) { super().merge({
      :package_name => 'postgis',
    }) }

    it {
      is_expected.to contain_package('Postgresql extension postgis').with({
        :ensure  => 'present',
        :name    => 'postgis',
      }).that_comes_before('Postgresql_psql[Add postgis extension to template_postgis]')
    }
  end

  context "when ensuring absence" do
    let (:params) { super().merge({
      :ensure       => 'absent',
      :package_name => 'postgis',
    }) }

    it {
      is_expected.to contain_postgresql_psql('Add postgis extension to template_postgis').with({
        :db      => 'template_postgis',
        :command => 'DROP EXTENSION postgis',
        :unless  => "SELECT t.count FROM (SELECT count(extname) FROM pg_extension WHERE extname = 'postgis') as t WHERE t.count != 1",
      }).that_requires('Postgresql::Server::Database[template_postgis]')
    }

    it {
      is_expected.to contain_package('Postgresql extension postgis').with({
        :ensure  => 'absent',
        :name    => 'postgis',
      })
    }

    context "when keeping package installed" do
      let (:params) { super().merge({
        :package_ensure => 'present',
      }) }

      it {
        is_expected.to contain_postgresql_psql('Add postgis extension to template_postgis').with({
          :db      => 'template_postgis',
          :command => 'DROP EXTENSION postgis',
          :unless  => "SELECT t.count FROM (SELECT count(extname) FROM pg_extension WHERE extname = 'postgis') as t WHERE t.count != 1",
        }).that_requires('Postgresql::Server::Database[template_postgis]')
      }

      it {
        is_expected.to contain_package('Postgresql extension postgis').with({
          :ensure  => 'present',
          :name    => 'postgis',
        }).that_requires('Postgresql_psql[Add postgis extension to template_postgis]')
      }
    end
  end
end
