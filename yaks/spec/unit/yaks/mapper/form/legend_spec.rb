RSpec.describe Yaks::Mapper::Form::Legend do
  subject(:legend) { described_class.create("a legend") }

  describe ".create" do
    its(:type) { should equal :legend }
    its(:label) { should eql "a legend" }

    context "with an `:if` option" do
      subject(:legend) { described_class.create("a legend", if: ->{ true }) }

      it "should set the attribute" do
        expect(legend.if.call).to be true
      end
    end
  end

  describe "#to_resource_fields" do
    include_context "yaks context"
    let(:mapper) { Yaks::Mapper.new(yaks_context) }

    it "should return an array of Resource::Form::Legend" do
      expect(legend.to_resource_fields(mapper))
        .to eql [Yaks::Resource::Form::Legend.new(label: "a legend", type: :legend)]
    end

    context "with a truthy condition" do
      subject(:legend) { described_class.create("a legend", if: ->{ true }) }

      it "should return an array of Resource::Form::Legend" do
        expect(legend.to_resource_fields(mapper).first)
          .to be_a Yaks::Resource::Form::Legend
      end
    end

    context "with a falsey condition" do
      subject(:legend) { described_class.create("a legend", if: ->{ false }) }

      it "should return an empty array" do
        expect(legend.to_resource_fields(mapper)).to eql []
      end
    end

    context "with a lambda for a label" do
      subject(:legend) { described_class.create(->{ self.class.to_s }) }

      it "should expand the lambda in the context of the mapper" do
        expect(legend.to_resource_fields(mapper))
          .to eql [Yaks::Resource::Form::Legend.new(label: "Yaks::Mapper", type: :legend)]
      end
    end
  end
end
