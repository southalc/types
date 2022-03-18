require 'spec_helper'

describe 'types::binary' do
  let(:title) { '/tmp/binary_spec.tmp' }
  let(:params) do
    {
      properties: {
        ensure:  'file',
        content: 'VHlwZXMgdW5pdCB0ZXN0Cg==',
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os.match?(%r{windows}i)
        let(:title) { 'C:\\Temp\\binary_spec.tmp' }
      else
        let(:title) { '/tmp/binary_spec.tmp' }
      end
      it { is_expected.to compile }
    end
  end
end
