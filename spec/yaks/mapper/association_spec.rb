require 'spec_helper'

describe Yaks::Mapper::Association do
  describe 'self_link' do
    context 'without a :self link' do
      subject { described_class.new(nil, nil, nil, Yaks::List(Yaks::Mapper::Link.new(:alternate, '/foo', {})), {}) }

      it 'should be nil' do
        expect(subject.self_link).to be_nil
      end
    end
  end

  context 'with a self link' do
    subject { described_class.new(nil, nil, nil, Yaks::List(Yaks::Mapper::Link.new(:self, '/self', {})), {}) }

    it 'should resolve to the self link' do
      expect(subject.self_link).to eq Yaks::Mapper::Link.new(:self, '/self', {})
    end
  end
end
