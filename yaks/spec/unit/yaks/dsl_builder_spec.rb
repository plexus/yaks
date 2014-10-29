require 'spec_helper'

RSpec.describe Yaks::DSLBuilder do
  class Buildable
    include Yaks::Attributes.new(:foo, :bar)

    def self.create(foo, bar)
      new(foo: foo, bar: bar)
    end

    def finalize
      update(foo: 7, bar: 8)
    end
  end

  subject { Yaks::DSLBuilder.new(Buildable) }

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
