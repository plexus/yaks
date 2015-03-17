RSpec.describe Yaks::Mapper::Form::Fieldset do
  include_context 'yaks context'
  let(:mapper) { Yaks::Mapper.new(yaks_context) }

  describe '#to_resource_fields' do
    context 'with dynamic elements' do
      let(:fieldset) do
        described_class.create({}) do
          dynamic do |object|
            text object.name
          end
        end
      end

      it 'should render them based on the mapped object' do
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
  end

end
