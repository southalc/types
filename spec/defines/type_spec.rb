require 'spec_helper'

describe 'types::type' do
  let(:title) { 'notify' }
  let(:params) do
    {
      hash: {
        unit_test: {
          message: 'Unit test',
        },
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_notify('unit_test') }
    end
  end
end
