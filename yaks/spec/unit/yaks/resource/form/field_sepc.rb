RSpec.describe Yaks::Resource::Form::Field do
  subject do
    described_class.new(value: 123)
  end

  describe '#value' do
    its(:value) { should eql 123 }

    context 'with a select box - with selection' do
      subject do
        described.class.new(type: :select, options: [
                              Yaks::Resource::Form::Field::Option.new(selected: false, value: 1),
                              Yaks::Resource::Form::Field::Option.new(selected: true, value: 2),
                              Yaks::Resource::Form::Field::Option.new(selected: false, value: 3),
                            ])
      end

      it 'should return the selected value' do
        expect( subject.value ).to eql 2
      end
    end

    context 'with a select box - no selection' do
      subject do
        described.class.new(type: :select, options: [
                              Yaks::Resource::Form::Field::Option.new(selected: false, value: 1),
                              Yaks::Resource::Form::Field::Option.new(selected: false, value: 2),
                              Yaks::Resource::Form::Field::Option.new(selected: false, value: 3),
                            ])
      end

      it 'should return nothing' do
        expect( subject.value ).to be nil
      end
    end
  end
end
