require 'spec_helper'

describe Yaks::Mapper::ClassMethods do
  subject { Class.new { extend Yaks::Mapper::ClassMethods } }

  describe 'attributes' do
    before do
      subject.attributes(:foo, :bar)
    end

    it 'should allow setting them' do
      expect( subject.attributes ).to eq [:foo, :bar]
    end

    describe 'with inheritance' do
      let(:child) { Class.new(subject) }
      before { child.attributes(:baz) }

      it 'should inherit attributes from the parent' do
        expect(child.attributes).to eq [:foo, :bar, :baz]
      end

      it 'should not alter the parent' do
        expect(subject.attributes).to eq [:foo, :bar]
      end
    end
  end
end
