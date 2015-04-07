RSpec.describe Yaks::Mapper::Attribute do
  include_context 'yaks context'

  subject(:attribute) { described_class.new(:the_name) }
  fake(:mapper)

  before do
    stub(mapper).load_attribute(:the_name) { 123 }
  end

  describe "#initialize" do
    its(:name) { should be :the_name }
  end

  describe "#add_to_resource" do
    it "should add itself to a resource based on a lookup" do
      expect(attribute.add_to_resource(Yaks::Resource.new, mapper , yaks_context))
        .to eql(Yaks::Resource.new(attributes: { :the_name => 123 }))
    end
  end
end
