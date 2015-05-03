RSpec.describe Yaks::Mapper::Form::Field::Option do
  include_context "yaks context"

  let(:mapper_class) do
    Class.new(Yaks::Mapper) do
      def color
        :yellow
      end
    end
  end

  let(:mapper) { mapper_class.new(yaks_context) }
  let(:args) {
    {
      value: ->{ color },
      label: ->{ :color },
      selected: ->{ true },
      disabled: ->{ true }
    }
  }

  let(:option) { described_class.new(args) }

  describe ".create" do
    it "should take the first argument as 'value'" do
      expect(described_class.create(0, label: 'zero'))
        .to eql Yaks::Mapper::Form::Field::Option.new(
          value: 0,
          label: 'zero'
        )
    end
  end

  describe "#to_resource_field_option" do
    let(:resource_field_option) { option.to_resource_field_option(mapper) }

    it "should expand procs in the context of the mapper" do
      expect(resource_field_option)
        .to eql Yaks::Resource::Form::Field::Option.new(
          value: :yellow,
          label: :color,
          selected: true,
          disabled: true
        )
    end

    context "with a truthy condition" do
      let(:args) { super().merge(if: ->{ true }) }

      it "should return an Option instance" do
        expect(resource_field_option).to be_a Yaks::Resource::Form::Field::Option
      end
    end

    context "with a falsey condition" do
      let(:args) { super().merge(if: ->{ false }) }

      it "should return nil" do
        expect(resource_field_option).to be_nil
      end
    end
  end
end
