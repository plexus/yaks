RSpec.describe Yaks::Resource::Form::Field do
  subject do
    described_class.new(name: 'foo', value: 123)
  end

  describe '#value' do
    its(:value) { should eql 123 }

    context 'with a select box - with selection' do
      subject do
        described_class.new(name: 'foo', type: :select, options: [
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 1),
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: true, value: 2),
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 3),
                            ])
      end

      it 'should return the selected value' do
        expect( subject.value ).to eql 2
      end
    end

    context 'with a select box - no selection' do
      subject do
        described_class.new(name: 'foo', type: :select, options: [
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 1),
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 2),
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 3),
                            ])
      end

      it 'should return nothing' do
        expect( subject.value ).to be nil
      end
    end
  end

  describe '#with_value' do
    context 'with a regular field' do
      it 'will update the given attributes' do
        expect(subject.with_value({ value: 321 }).value).to eql 321
      end
    end

    context 'with a select field' do
      subject do
        described_class.new(name: 'foo', type: :select, options: [
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 1),
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 2),
                              Yaks::Resource::Form::Field::Option.new(label: 'foo', selected: false, value: 3),
                            ])
      end

      it 'will update the affected option' do
        expect(subject.with_value({ value: 2 }).value).to eql 2
      end
    end
  end
end
