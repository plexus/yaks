require 'spec_helper'

RSpec.describe Yaks::FP::Callable do
  it 'should delegate to_proc to method(:call)' do
    obj = Class.new do
      include Yaks::FP::Callable

      def call(x) ; x * x ; end
    end.new

    expect([1,2,3].map(&obj)).to eql [1,4,9]
  end
end
