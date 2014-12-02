require 'spec_helper'

RSpec.describe Yaks::Configurable do
  class Creatable
    def self.create(*args, &block)
      ["->", *args, block.call]
    end
  end

  subject do
    Class.new do
      extend Yaks::Configurable
      include Yaks::Attributes.new(foo: [])

      config_method :bar, append_to: :foo, create: Creatable
      config_method :baz, append_to: :foo, create: Creatable, defaults: {bar: 'baz'}
    end
  end

  it 'should generate the config method' do
    expect(
      subject.new.bar(1,2,3) { 4 }
                 .bar(:baz)  { :booz }
                 .foo
    ).to eql [["->", 1, 2, 3, {}, 4], ["->", :baz, {}, :booz]]
  end

  it 'should allow setting defaults' do
    expect(
      subject.new.baz(1,2,3, foo: 'bar') { 4 }
                 .foo
    ).to eql [["->", 1, 2, 3, {foo: 'bar', bar: 'baz'}, 4]]
  end

  it 'should allow overriding defaults' do
    expect(
      subject.new.baz(1,2,3, bar: 'qux') { 4 }
                 .foo
    ).to eql [["->", 1, 2, 3, {bar: 'qux'}, 4]]
  end

  it 'should be able to take an already instantiated object of the right type' do
    instance = Creatable.new
    expect(
      subject.new.bar(instance).foo
    ).to eql [instance]
  end

  it 'should only take the instance verbatim if it is the only argument' do
    instance = Creatable.new
    expect(
      subject.new.bar(instance, 1) {}.foo
    ).to eql [["->", instance, 1, {}, nil]]
  end
end
