require 'spec_helper'

describe Yaks::Mapper do
  let(:mapper_class) { Class.new(Yaks::Mapper) }

  before do
    mapper_class.attributes :foo, :bar
  end

  it 'should make the class configured attributes available on the instance' do
    expect(mapper_class.new(Object.new).attributes).to eq Yaks::List(:foo, :bar)
  end
end
