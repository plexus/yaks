require 'spec_helper'

RSpec.describe Yaks::StatefulBuilder do
  class Buildable
    include Yaks::Attributes.new(:foo, :bar)

    def self.create(foo, bar)
      new(foo: foo, bar: bar)
    end

    def finalize
      with(foo: 7, bar: 8)
    end

    def wrong_type(x, y)
      "foo #{x} #{y}"
    end

  end

  subject { Yaks::StatefulBuilder.new(Buildable, [:foo, :bar, :update, :finalize, :wrong_type]) }

  it 'should keep state' do
    expect(
      subject.create(3, 4) do
        foo 7
        update bar: 6
      end.to_h
    ).to eql(foo: 7, bar: 6)
  end

  it 'should unwrap again' do
    expect( subject.create(3, 4) { finalize } ).to eql Buildable.new(foo: 7, bar: 8)
  end

  describe 'kind_of?' do
    it 'should test if the returned thing is of the right type' do
      expect { subject.create(3, 4) { wrong_type(1,'2') }}.to raise_exception Yaks::IllegalStateError, 'Buildable#wrong_type(1, "2") returned "foo 1 2". Expected instance of Buildable'
    end
  end
end
