RSpec.describe Yaks::Mapper::Attribute do
  include_context 'yaks context'

  let(:attribute_with_block) { described_class.create(:the_name) { "Alice" } }

  subject(:attribute) { described_class.create(:the_name) }
  fake(:mapper)

  before do
    stub(mapper).load_attribute(:the_name) { 123 }
    stub(mapper).object { fake(name: "Bob") }
  end

  describe ".create" do
    its(:name) { should be :the_name }
    its(:block) { should be_nil }

    it "should accept two parameter" do
      expect{described_class.create(:the_name, {})}.not_to raise_error()
    end

    context "with block" do
      subject(:attribute) { attribute_with_block }

      its(:block) { should_not be_nil }

      it "should store the given block" do
        expect(subject.block.call).to eq("Alice")
      end
    end
  end

  describe "#add_to_resource" do
    it "should add itself to a resource based on a lookup" do
      expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
        .to eql(Yaks::Resource.new(attributes: {the_name: 123}))
    end

    context "when the attribute has a block" do
      subject(:attribute) { attribute_with_block }

      it "should add itself to a resource with the block value" do
        expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
          .to eql(Yaks::Resource.new(attributes: {the_name: "Alice"}))
      end

      context "using the mapper context" do
        let(:attribute) { described_class.create(:the_name) { object.name } }

        it "should add itself to a resource with the block value" do
          expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
            .to eql(Yaks::Resource.new(attributes: {the_name: "Bob"}))
        end
      end
    end
  end
end
