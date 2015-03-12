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

  describe '#to_resource' do
    it 'creates a Yaks::Resource::Form::Field with the same attributes' do
      expect(field.to_resource(mapper)).to eql Yaks::Resource::Form::Field.new(full_args)
    end

    context 'with dynamic attributes' do
      let(:name) { ->{ month } }

      it 'should expand attributes using the mapper' do
        expect(field.to_resource(mapper).name).to eql 'January'
      end
    end

    context 'with a falsey if condition' do
      let(:args) { super().merge(if: ->{ false })}
      it 'returns nil' do
        expect(field.to_resource(mapper)).to be_nil
      end
    end

    context 'with a truthy if condition' do
      let(:args) { super().merge(if: ->{ true })}
      it 'returns nil' do
        expect(field.to_resource(mapper)).to be_a Yaks::Resource::Form::Field
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
        expect(field.to_resource(mapper)).to eql form_field
      end
    end
  end
end
