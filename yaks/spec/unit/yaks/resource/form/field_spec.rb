RSpec.describe Yaks::Resource::Form::Field do
  subject do
    described_class.new(type: 'text', name: 'foo', value: 123)
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
      it 'should update the given attributes' do
        expect(subject.with_value(321).value).to eql 321
      end
    end

    context 'with a select field' do
      subject do
        described_class.new(name: 'foo', type: :select, options: [
          Yaks::Resource::Form::Field::Option.new(label: 'f', selected: true,  value: "1"),
          Yaks::Resource::Form::Field::Option.new(label: 'f', selected: false, value: "2"),
          Yaks::Resource::Form::Field::Option.new(label: 'f', selected: true,  value: "3"),
          Yaks::Resource::Form::Field::Option.new(label: 'f', selected: false, value: "4"),
        ])
      end

      let(:updated) { subject.with_value("2") }

      it 'should keep existing attributes' do
        expect([updated.name, updated.type]).to eq ['foo', :select]
      end

      context 'when changing from a previous value' do
        it 'should update the affected option' do
          expect(updated.value).to eq "2"
        end

        it 'should reuse existing Option instances' do
          expect(updated.options.last).to equal subject.options.last
        end

        it 'should unset all selected options' do
          expect(updated.options.map(&:selected)).to eq [false, true, false, false]
        end
      end

      context 'when keeping the old value value' do
        let(:updated) { subject.with_value("1") }

        it 'should not change the value' do
          expect(updated.value).to eq "1"
        end

        it 'should reuse existing Option instances' do
          expect(updated.options.first).to equal subject.options.first
        end
      end
    end
  end
end
