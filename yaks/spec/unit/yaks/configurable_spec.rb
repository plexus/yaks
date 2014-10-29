require 'spec_helper'

RSpec.describe Yaks::Configurable do
  class Creatable
    def self.create(*args, &block)
      ["->", *args, block.call]
    end
  end

  subject do
    Class.new do
      include Yaks::Attributes.new(foo: []), Yaks::Configurable

      config_method :bar, append_to: :foo, create: Creatable
    end
  end

  it 'should generate the config method' do
    expect(
      subject.new.bar(1,2,3) { 4 }
                 .bar(:baz)  { :booz }
                 .foo
    ).to eql [["->", 1, 2, 3, 4], ["->", :baz, :booz]]
  end
end
