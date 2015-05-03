RSpec.describe Yaks::Mapper::Form::Fieldset do
  include_context 'yaks context'
  let(:mapper) { Yaks::Mapper.new(yaks_context) }

  describe ".create" do
    let(:fieldset) {
      described_class.create do
        text :first_name
        text :last_name
      end
    }

    it "should take a config block" do
      expect(fieldset.config)
        .to eql Yaks::Mapper::Form::Config.new(
          fields: [
            Yaks::Mapper::Form::Field.new(name: :first_name, type: :text),
            Yaks::Mapper::Form::Field.new(name: :last_name, type: :text)
          ]
        )
    end

    context "with extra options" do
      let(:fieldset) {
        described_class.create if: true  do
          text :first_name
        end
      }

      it "should take an :if option (the rest doesn't make sense for a fieldset)" do
        expect(fieldset.config)
          .to eql Yaks::Mapper::Form::Config.new(
            fields: [
              Yaks::Mapper::Form::Field.new(name: :first_name, type: :text)
            ],
            if: true
          )
      end
    end
  end

  describe "#to_resource_fields" do
    context "with dynamic elements" do
      let(:fieldset) {
        described_class.create do
          dynamic do |object|
            text object.name
          end
        end
      }

      it "should render them based on the mapped object" do
        mapper.call(fake(name: :anthony)) # hack to set the mapper's object
        expect(fieldset.to_resource_fields(mapper)).to eql(
          [
            Yaks::Resource::Form::Fieldset.new(
              fields: [
                Yaks::Resource::Form::Field.new(name: :anthony, type: :text)
              ]
            )
          ]
        )
      end
    end

    context "with a truthy `:if` condition" do
      let(:fieldset) {
        described_class.create if: ->{ true } do
        end
      }

      it "should return an array of fieldsets" do
        expect(fieldset.to_resource_fields(mapper).first)
          .to be_a Yaks::Resource::Form::Fieldset
      end
    end

    context "with a falsey `:if` condition" do
      let(:fieldset) {
        described_class.create if: ->{ false } do
        end
      }

      it "should return nil" do
        expect(fieldset.to_resource_fields(mapper).first).to be_nil
      end
    end
  end
end
