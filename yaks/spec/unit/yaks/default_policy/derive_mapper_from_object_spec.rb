RSpec.describe Yaks::DefaultPolicy, '#derive_mapper_from_object' do
  subject(:policy) { described_class.new(options) }

  let(:options) { {} }

  context 'for a single instance' do
    it 'should derive it by name' do
      expect(policy.derive_mapper_from_object(Soy.new)).to be SoyMapper
    end

    context 'given a namespace' do
      let(:options) { {namespace: MyMappers} }

      it 'should look inside the namespace' do
        expect(policy.derive_mapper_from_object(Soy.new)).to be MyMappers::SoyMapper
      end
    end
  end

  context 'for array-like objects' do
    context 'given an empty array' do
      it 'should return the vanilla CollectionMapper' do
        expect(policy.derive_mapper_from_object([])).to be Yaks::CollectionMapper
      end
    end

    it 'should find the mapper based on naming' do
      expect(policy.derive_mapper_from_object([Soy.new])).to be SoyCollectionMapper
    end

    context 'if no collection mapper with a similar name is defined' do
      let(:options) { {namespace: Namespace} }

      it 'should look for a CollectionMapper in the namespace' do
        expect(policy.derive_mapper_from_object([Wheat.new])).to be(
          Namespace::CollectionMapper
        )
      end
    end
  end

  context 'for a model class inside a module' do
    let(:options) { {namespace: Namespace} }

    it 'should take the non-qualified classname, and search the mapper namespace with that' do
      expect(policy.derive_mapper_from_object(Namespace::Nested::Rye.new)).to be(
        Namespace::RyeMapper
      )
    end

    it 'should take the non-qualified classname when looking for a collection mapper' do
      expect(policy.derive_mapper_from_object([Namespace::Nested::Rye.new])).to be(
        Namespace::RyeCollectionMapper
      )
    end
  end

  context 'when trying to lookup CollectionMapper results in something other than an NameError' do
    let(:options) { {namespace: DislikesCollectionMapper} }

    it 'should propagate the error' do
      expect {
        policy.derive_mapper_from_object([])
      }.to raise_error
    end
  end

  context 'when trying to lookup a specific collection mapper results in something other than an NameError' do
    let(:options) { {namespace: DislikesOtherMappers} }

    it 'should propagate the error' do
      expect {
        policy.derive_mapper_from_object([Namespace::Nested::Rye.new])
      }.to raise_error
    end
  end

  context 'when a mapper exists for a superclass' do
    let(:options) { {namespace: MyMappers} }

    it 'should use the superclass mapper' do
      expect(policy.derive_mapper_from_object(Namespace::Nested::Mung.new)).to be(MyMappers::BeanMapper)
    end
  end

  context 'when no mapper is found' do
    it 'should give a nice message' do
      expect {
        policy.derive_mapper_from_object(Namespace::Nested::Mung.new)
      }.to raise_error /Failed to find a mapper for #<Namespace::Nested::Mung:0x\h+>. Did you mean to implement MungMapper\?/
    end
  end
end
