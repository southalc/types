require 'spec_helper'

describe 'types' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it do
        is_expected.to contain_types__type('augeas')
        is_expected.to contain_types__type('cron')
        is_expected.to contain_types__type('exec')
        is_expected.to contain_types__type('file')
        is_expected.to contain_types__type('file_line')
        is_expected.to contain_types__type('filebucket')
        is_expected.to contain_types__type('group')
        is_expected.to contain_types__type('host')
        is_expected.to contain_types__type('mount')
        is_expected.to contain_types__type('package')
        is_expected.to contain_types__type('resources')
        is_expected.to contain_types__type('schedule')
        is_expected.to contain_types__type('scheduled_task')
        is_expected.to contain_types__type('selboolean')
        is_expected.to contain_types__type('selmodule')
        is_expected.to contain_types__type('service')
        is_expected.to contain_types__type('ssh_authorized_key')
        is_expected.to contain_types__type('sshkey')
        is_expected.to contain_types__type('stage')
        is_expected.to contain_types__type('tidy')
        is_expected.to contain_types__type('user')
        is_expected.to contain_types__type('yumrepo')
        is_expected.to contain_types__type('zfs')
        is_expected.to contain_types__type('zone')
        is_expected.to contain_types__type('zpool')
      end
    end
  end
end
