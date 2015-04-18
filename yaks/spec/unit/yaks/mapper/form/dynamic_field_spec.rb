RSpec.describe Yaks::Mapper::Form::DynamicField do
  describe ".create" do
    it "take a block" do
      expect(described_class.create { :foo }.block.call).to equal :foo
    end

    it "should ignore any options hash given" do
      expect { described_class.create(foo: :bar) }.to_not raise_error
    end
  end

  describe "#to_resource_fields" do
    include_context "yaks context"
    let(:mapper) { Yaks::Mapper.new(yaks_context) }
    let(:field) {
      described_class.create do |obj|
        text :first_name, value: obj
        text :last_name
      end
    }

    it "should return an array of fields" do
      mapper.call("Arne")
      expect(field.to_resource_fields(mapper)).to eql [
        Yaks::Resource::Form::Field.new(name: :first_name, type: :text, value: "Arne"),
        Yaks::Resource::Form::Field.new(name: :last_name, type: :text)
      ]
    end
  end
end
