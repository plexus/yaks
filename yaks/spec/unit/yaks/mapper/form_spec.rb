RSpec.describe Yaks::Mapper::Form do
  include_context 'yaks context'

  let(:form)   { described_class.create( full_args ) }
  let(:name)      { :the_name }
  let(:full_args) { {name: name}.merge(args) }
  let(:args) {
    {
      action: '/foo',
      title: 'a title',
      method: 'PATCH',
      media_type: 'application/hal+json',
      fields: fields
    }
  }
  let(:fields) { [] }

  describe '.create' do
    it 'should have a name of nil when ommitted' do
      expect(described_class.create.name).to be_nil
    end
  end

  describe '#add_to_resource' do
    let(:mapper) { Yaks::Mapper.new(yaks_context) }
    let(:resource) { form.new.add_to_resource(Yaks::Resource.new, mapper, nil) }

    context 'with fields' do
      let(:fields) {
        [
          Yaks::Mapper::Form::Field.new(
            name: 'field name',
            label: 'field label',
            type: 'text',
            value: 7
          )
        ]
      }
    end

    context 'with a truthy condition' do
      let(:form) { described_class.create { condition { true }}}

      it 'should add the form' do
        expect(form.add_to_resource(Yaks::Resource.new, mapper, nil).forms.length).to be 1
      end
    end

    context 'with a falsey condition' do
      let(:form) { described_class.create { condition { false }}}

      it 'should not add the form' do
        expect(form.add_to_resource(Yaks::Resource.new, mapper, nil).forms.length).to be 0
      end
    end

  end
end
