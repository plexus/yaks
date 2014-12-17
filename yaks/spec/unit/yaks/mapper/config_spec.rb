RSpec.describe Yaks::Mapper::Config do

  describe '#add_attributes' do
    it 'should add attributes' do
      expect(subject.add_attributes(:bar).add_attributes(:baz)).to eql described_class.new(
        attributes: [
          Yaks::Mapper::Attribute.new(:bar),
          Yaks::Mapper::Attribute.new(:baz),
        ]
      )
    end
  end
end
