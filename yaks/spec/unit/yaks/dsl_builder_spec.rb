require 'spec_helper'

RSpec.describe Yaks::DSLBuilder do
  class Buildable
    include Yaks::Attributes.new(:foo, :bar)

    def self.create(foo, bar)
      new(foo: foo, bar: bar)
    end

    def finalize
      yield
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
    expect( subject.create(3, 4) { finalize {7} } ).to equal 7
  end
end
