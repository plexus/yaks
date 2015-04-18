RSpec.describe Yaks::Mapper::Form::Field do
  include_context 'yaks context'

  let(:field)     { described_class.new( full_args ) }
  let(:name)      { :the_field }
  let(:full_args) { {name: name, options: options}.merge(args) }
  let(:options)   { [] }
  let(:args) {
    {
      label: 'a label',
      type: 'text',
      value: 'hello'
    }
  }

  let(:mapper) do
    Class.new(Yaks::Mapper) do
      def month ; 'January' ; end
    end.new(yaks_context)
  end

  describe '.create' do
    it 'can take all args as a hash' do
      expect(described_class.create(full_args)).to eql described_class.new(full_args)
    end

    it 'can take a name as a positional arg' do
      expect(described_class.create(name, args)).to eql described_class.new(full_args)
    end

    it 'can take only a name' do
      expect(described_class.create(name)).to eql described_class.new(name: :the_field)
    end
  end

  describe '#to_resource_fields' do
    it 'creates a Yaks::Resource::Form::Field with the same attributes' do
      expect(field.to_resource_fields(mapper)).to eql [Yaks::Resource::Form::Field.new(full_args)]
    end

    context 'with dynamic attributes' do
      let(:name) { ->{ month } }

      it 'should expand attributes using the mapper' do
        expect(field.to_resource_fields(mapper).first.name).to eql 'January'
      end
    end

    context 'with a falsey if condition' do
      let(:args) { super().merge(if: ->{ false })}
      it 'returns an empty array' do
        expect(field.to_resource_fields(mapper)).to eql []
      end
    end

    context 'with a truthy if condition' do
      let(:args) { super().merge(if: ->{ true })}
      it 'returns a field' do
        expect(field.to_resource_fields(mapper).first).to be_a Yaks::Resource::Form::Field
      end
    end

    context 'with select optons' do
      let(:options) {
        [
          Yaks::Mapper::Form::Field::Option.new(
            label: 'Jan',
            value: ->{ 'January' },
            selected: ->{ month == 'January' }
          ),
          Yaks::Mapper::Form::Field::Option.new(
            label: 'Feb',
            value: ->{ 'February' },
            selected: ->{ month == 'February' }
          )
        ]
      }

      it 'should convert them to Yaks::Form* objects' do
        form_field = Yaks::Resource::Form::Field.new(
          name: :the_field,
          label: "a label",
          options: [
            Yaks::Resource::Form::Field::Option.new(value: "January", label: "Jan", selected: true),
            Yaks::Resource::Form::Field::Option.new(value: "February", label: "Feb")
          ],
          type: "text",
          value: "hello"
        )
        expect(field.to_resource_fields(mapper)).to eql [form_field]
      end
    end
  end

  describe "#resource_options" do
    context "when empty" do
      it "should always be the same identical object" do
        opt1 = described_class.new(name: :foo).resource_options(mapper)
        opt2 = described_class.new(name: :bar).resource_options(mapper)
        expect(opt1).to eql []
        expect(opt1).to equal opt2
      end
    end

    context "with select options" do
      let(:options) do
        [
          Yaks::Mapper::Form::Field::Option.new(value: 0, label: "zero"),
          Yaks::Mapper::Form::Field::Option.new(value: 1, label: "one"),
          Yaks::Mapper::Form::Field::Option.new(value: 2, label: "two", if: ->{ false })
        ]
      end

      it "should map to Resource::Field::Option instances" do
        expect(field.resource_options(mapper))
          .to eql [
            Yaks::Resource::Form::Field::Option.new(value: 0, label: "zero"),
            Yaks::Resource::Form::Field::Option.new(value: 1, label: "one")
          ]
      end
    end
  end

  describe "#resource_attributes" do
    it "should have all the HTML form field attributes" do
      expect(field.resource_attributes).to eql [
        :name, :label, :type, :required, :rows, :value, :pattern,
        :maxlength, :minlength, :size, :readonly, :multiple, :min,
        :max, :step, :list, :placeholder, :checked, :disabled
      ]
    end
  end
end
