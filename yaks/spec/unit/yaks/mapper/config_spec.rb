RSpec.describe Yaks::Mapper::Config do
  describe '#add_attributes' do
    it 'should add attributes' do
      expect(subject.add_attributes(:bar).add_attributes(:baz)).to eql described_class.new(
        attributes: [
          Yaks::Mapper::Attribute.create(:bar),
          Yaks::Mapper::Attribute.create(:baz),
        ]
      )
    end
  end
end
