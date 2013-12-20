require 'spec_helper'

describe Yaks::MapperConfig do
  describe 'adding attributes' do
    it 'should add attributes' do
      expect(subject.attributes(:foo, :bar, :baz).attributes)
        .to eq Hamster.list(:foo, :bar, :baz)
    end

    it 'should be chainable' do
      expect(
        subject
          .attributes(:foo, :bar)
          .attributes(:baz)
          .attributes
      ).to eq Hamster.list(:foo, :bar, :baz)
    end
  end
end
