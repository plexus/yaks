RSpec.describe Yaks::Mapper::Form::Config do
  let(:config) { described_class.new }

  describe ".create" do
    let(:config) {
      described_class.create name: :bar, method: "POST"
    }

    it "should take an attribute hash" do
      expect(config)
        .to eql Yaks::Mapper::Form::Config.new(
          name: :bar,
          method: "POST"
        )
    end
  end

  describe ".build" do
    context "with no arguments" do
      it "should create a default Form::Config" do
        expect(described_class.build).to eql described_class.new
      end
    end

    context "with a block" do
      let(:config) {
        described_class.build name: :bar do
          method "DELETE"
          password :secret
        end
      }

      it "should evaluate as Form DSL" do
        expect(config)
          .to eql Yaks::Mapper::Form::Config.new(
            name: :bar,
            method: "DELETE",
            fields: [
              Yaks::Mapper::Form::Field.new(name: :secret, type: :password)
            ]
          )
      end
    end
  end

  describe ".build_with_object" do
    let(:config) {
      described_class.build_with_object "the_object" do |obj|
        title obj
      end
    }

    it "should pass the object to the config block" do
        expect(config)
          .to eql Yaks::Mapper::Form::Config.new(
            title: "the_object"
          )
    end
  end

  describe "#condition" do
    it "should work with a lambda" do
      expect(config.condition(->{ :okay }).if.call).to equal :okay
    end

    it "should work with a block" do
      expect(config.condition { :okay }.if.call).to equal :okay
    end
  end

  describe "#to_resource_fields" do
    include_context 'yaks context'
    let(:mapper) { Yaks::Mapper.new(yaks_context) }
    let(:config) {
      described_class.build do
        fieldset do
          text :first_name
          text :last_name
        end
      end
    }

    it "should map to resource fields" do
      expect(config.to_resource_fields(mapper))
        .to eql [
          Yaks::Resource::Form::Fieldset.new(
            fields: [
              Yaks::Resource::Form::Field.new(name: :first_name, type: :text),
              Yaks::Resource::Form::Field.new(name: :last_name, type: :text)
            ]
          )
        ]
    end
  end
end
