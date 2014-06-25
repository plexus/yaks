require 'spec_helper'

RSpec.describe Yaks::Mapper::Attribute do
  include_context 'yaks context'

  subject(:attribute) { described_class.new(:the_name) }
  let(:mapper) { double(Yaks::Mapper) }

  its(:name) { should be :the_name }

  it 'should add itself to a resource based on a lookup' do
    expect(mapper).to receive(:load_attribute).with(:the_name).and_return(123)
    expect(attribute.add_to_resource(Yaks::Resource.new, mapper , yaks_context)).to eql(
      Yaks::Resource.new(attributes: { :the_name => 123 })
    )
  end
end
