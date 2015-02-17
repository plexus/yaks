RSpec.describe Yaks::Mapper::Form::Field::Option do
  include_context 'yaks context'

  let(:mapper_class) do
    Class.new(Yaks::Mapper) do
      def color
        :yellow
      end
    end
  end

  let(:mapper) { mapper_class.new(yaks_context) }

  let(:option) { described_class.new(value: ->{color}, label: :color) }

  it 'should expand procs in the context of the mapper' do
    expect(option.to_resource_field_option(mapper)).to eql Yaks::Resource::Form::Field::Option.new(value: :yellow, label: :color, selected: false)
  end
end
