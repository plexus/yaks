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

  subject do
    Yaks::StatefulBuilder.new(Buildable) do
      def_set :foo, :bar
      def_forward :finalize, :wrong_type, :update
    end
  end

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

end
