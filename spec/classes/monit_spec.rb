require 'spec_helper'

describe 'monit', :type => :class do

  shared_examples 'debian-monit' do |os, codename, status|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}
    let(:title) { 'monit-basic' }

    it 'should have service status' do
      should contain_service('monit').with({
        'hasstatus' => status,
      })
    end

    it 'should compile' do
      should contain_file('/etc/monit/monitrc')
      should contain_file('/etc/monit/conf.d')
      should contain_file('/etc/logrotate.d/monit')
      should contain_service('monit')
    end
  end


  context "osfamily = RedHat" do
    let :facts do
      {
        :osfamily        => 'RedHat',
        :lsbdistid       => 'RedHat',
        :kernel          => 'Linux',
        :operatingsystem => 'CentOS',
      }
    end

    context "default usage (osfamily = RedHat)" do
      let(:title) { 'monit-syslog' }

      let :params do
        {
          :logfile => 'blah syslog blah',
        }
      end

      it 'should compile' do
        should_not contain_file('/etc/logrotate.d/monit')
        should contain_file('/etc/monit.conf').with({
          'content' => /^set logfile blah syslog blah$/,
        })
      end
    end

    context "default usage (osfamily = RedHat)" do
      let(:title) { 'monit-basic' }

      it 'should compile' do
        should contain_file('/etc/monit.conf')
        should contain_file('/etc/monit.d')
        should contain_file('/etc/logrotate.d/monit')
        should contain_service('monit')
      end

      it 'should have service status' do
        should contain_service('monit').with({
          'hasstatus' => true,
        })
      end
    end
  end

  context 'on debian-like system' do
    it_behaves_like 'debian-monit', 'Debian', 'squeeze', false
    it_behaves_like 'debian-monit', 'Debian', 'wheezy', true
    it_behaves_like 'debian-monit', 'Ubuntu', 'precise', true
  end

end
