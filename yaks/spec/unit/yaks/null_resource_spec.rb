RSpec.describe Yaks::NullResource do
  subject(:null_resource) { described_class.new }

  describe '#initialize' do
    it 'should have defaults for everything' do
      expect( described_class.new.to_h ).to eql(
        type: nil,
        rels: [],
        links: [],
        attributes: {},
        subresources: [],
        forms: [],
        collection: false
      )
    end

    it 'should allow setting rels' do
      expect( described_class.new(rels: [:self]).rels ).to eql [:self]
    end

    it 'should allow setting the collection flag' do
      expect( described_class.new(collection: true).collection ).to be true
    end

    it 'should not allow attributes in the contstructor' do
      expect( described_class.new(attributes: {foo: :bar}).attributes ).to eql({})
    end
  end

  describe "#attributes" do
    its(:attributes) { should eql({}) }
  end

  describe "#links" do
    its(:links) { should eql [] }
  end

  describe "#rels" do
    its(:rels) { should eql [] }
  end

  describe "#subresources" do
    its(:subresources) { should eql [] }
  end

  describe "#collection?" do
    its(:collection?) { should be false }

    context 'when a collection' do
      subject(:null_resource) { described_class.new( collection: true ) }
      its(:collection?) { should be true }
    end
  end

  describe "#null_resource?" do
    its(:null_resource?) { should be true }
  end

  describe "#seq" do
    its(:seq) { should eql [] }
  end

  describe "#[]" do
    it 'should contain nothing' do
      expect( null_resource[:key] ).to be_nil
    end
  end

  describe "#type" do
    its(:type) { should be_nil }
  end

  describe '#each' do
    its(:each) { should be_a Enumerator }

    it 'should not yield anything' do
      null_resource.each { raise }
    end
  end

  describe "#merge_attributes" do
    it 'should not allow updating attributes' do
      expect { null_resource.merge_attributes({}) }.to raise_error(
        Yaks::UnsupportedOperationError, "Operation merge_attributes not supported on Yaks::NullResource"
      )
    end
  end

  describe "#add_link" do
    it 'should not allow adding links' do
      expect { null_resource.add_link(nil) }.to raise_error(
        Yaks::UnsupportedOperationError, "Operation add_link not supported on Yaks::NullResource"
      )
    end
  end

  describe "#add_form" do
    it 'should not allow adding forms' do
      expect { null_resource.add_form(nil) }.to raise_error(
        Yaks::UnsupportedOperationError, "Operation add_form not supported on Yaks::NullResource"
      )
    end
  end

  describe "#add_subresource" do
    it 'should not allow adding subresources' do
      expect { null_resource.add_subresource(nil) }.to raise_error(
        Yaks::UnsupportedOperationError, "Operation add_subresource not supported on Yaks::NullResource"
      )
    end
  end

  describe '#map' do
    context 'when a collection' do
      it 'should always return []' do
        expect( described_class.new(collection: true).map{} ).to eql []
      end
    end

    context 'when not a collection' do
      it 'should raise an error' do
        expect { null_resource.map{} }.to raise_error(
          Yaks::UnsupportedOperationError, "Operation map not supported on Yaks::NullResource"
        )
      end
    end
  end
end
