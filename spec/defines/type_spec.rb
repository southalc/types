require 'spec_helper'

describe 'types::type' do
  let(:title) { 'notify' }
  let(:params) {{
    :hash => {
      :unit_test => {
        :message  => 'Unit test'
      }
    }
  }}
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
