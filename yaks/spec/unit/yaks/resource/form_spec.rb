RSpec.describe Yaks::Resource::Form do
  let(:fields) {
    [
      Yaks::Resource::Form::Field.new(name: :foo, value: '123', type: 'text'),
      Yaks::Resource::Form::Field.new(name: :bar, value: '+32 477 123 123', type: 'tel')
    ]
  }

  subject(:form) {
    described_class.new(name: :create_foo, fields: fields)
  }

  describe '#[]' do
    it 'should find a field value by field name' do
      expect(subject[:bar])
        .to eq '+32 477 123 123'
    end
  end

  describe '#values' do
    it 'should return all field values in a hash' do
      expect(subject.values).to eql(foo: '123', bar: '+32 477 123 123')
    end
  end

  describe '#fields_flat' do
    let(:fields) do
      [
        Yaks::Resource::Form::Fieldset.new(fields: [
          Yaks::Resource::Form::Field.new(name: :foo, value: '123', type: 'text'),
          Yaks::Resource::Form::Field.new(name: :bar, value: '+32 477 123 123', type: 'tel')
        ]),
        Yaks::Resource::Form::Fieldset.new(fields: [
          Yaks::Resource::Form::Fieldset.new(fields: [
            Yaks::Resource::Form::Field.new(name: :qux, value: '777', type: 'text'),
          ]),
          Yaks::Resource::Form::Field.new(name: :quux, value: '999', type: 'tel')
        ])
      ]
    end

    it 'should flatten fieldsets' do
      expect(subject.fields_flat).to eql [
        Yaks::Resource::Form::Field.new(name: :foo, value: '123', type: 'text'),
        Yaks::Resource::Form::Field.new(name: :bar, value: '+32 477 123 123', type: 'tel'),
        Yaks::Resource::Form::Field.new(name: :qux, value: '777', type: 'text'),
        Yaks::Resource::Form::Field.new(name: :quux, value: '999', type: 'tel')
      ]
    end
  end

end
