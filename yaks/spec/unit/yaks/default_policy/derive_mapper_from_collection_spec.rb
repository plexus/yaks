RSpec.describe Yaks::DefaultPolicy, '#derive_mapper_from_collection' do
  subject(:policy) { described_class.new(options) }

  let(:options) { {} }

  context 'given an empty array' do
    it 'should return the vanilla CollectionMapper' do
      expect(policy.derive_mapper_from_collection([])).to be Yaks::CollectionMapper
    end
  end

  it 'should find the mapper based on naming' do
    expect(policy.derive_mapper_from_collection([Soy.new])).to be SoyCollectionMapper
  end

  it 'should not care about the object module' do
    expect(policy.derive_mapper_from_collection([Grain::Soy.new])).to be SoyCollectionMapper
  end

  context 'if no collection mapper with a similar name is defined' do
    let(:options) { {namespace: Namespace} }

    it 'should look for a CollectionMapper in the namespace' do
      expect(policy.derive_mapper_from_collection([WildSoy.new])).to be(Namespace::CollectionMapper)
    end

    context 'when trying to lookup CollectionMapper results in something other than an NameError' do
      let(:options) { {namespace: DislikesCollectionMapper} }

      it 'should propagate the error' do
        expect {
          policy.derive_mapper_from_object([])
        }.to raise_error(RuntimeError)
      end
    end

    context 'when trying to lookup a specific collection mapper results in something other than an NameError' do
      let(:options) { {namespace: DislikesOtherMappers} }

      it 'should propagate the error' do
        expect {
          policy.derive_mapper_from_object([Namespace::Nested::Rye.new])
        }.to raise_error(RuntimeError)
      end
    end
  end
end
