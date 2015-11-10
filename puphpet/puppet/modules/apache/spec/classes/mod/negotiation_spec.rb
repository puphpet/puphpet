require 'spec_helper'

describe 'apache::mod::negotiation', :type => :class do
  describe "OS independent tests" do

    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :kernel                 => 'Linux',
        :lsbdistcodename        => 'squeeze',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :id                     => 'root',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end

    context "default params" do
      let :pre_condition do
        'class {"::apache": }'
      end
      it { should contain_class("apache") }
      it do
        should contain_file('negotiation.conf').with( {
          :ensure  => 'file',
          :content => 'LanguagePriority en ca cs da de el eo es et fr he hr it ja ko ltz nl nn no pl pt pt-BR ru sv zh-CN zh-TW
ForceLanguagePriority Prefer Fallback
',
        } )
      end
    end

    context 'with force_language_priority parameter' do
      let :pre_condition do
        'class {"::apache": default_mods => ["negotiation"]}'
      end
      let :params do
        { :force_language_priority => 'Prefer' }
      end
      it do
        should contain_file('negotiation.conf').with( {
          :ensure  => 'file',
          :content => /^ForceLanguagePriority Prefer$/,
        } )
      end
    end

    context 'with language_priority parameter' do
      let :pre_condition do
        'class {"::apache": default_mods => ["negotiation"]}'
      end
      let :params do
        { :language_priority => [ 'en', 'es' ] }
      end
      it do
        should contain_file('negotiation.conf').with( {
          :ensure  => 'file',
          :content => /^LanguagePriority en es$/,
        } )
      end
    end
  end
end
