RSpec.describe Yaks::DefaultPolicy, '#derive_mapper_from_object' do
  subject(:policy) { described_class.new }

  context 'for a single instance' do
    let(:object) { Soy.new }

    it 'should call derive_mapper_for_item' do
      stub(policy).derive_mapper_from_item(object) { SoyMapper }
      policy.derive_mapper_from_object(object)
      expect(policy).to have_received.derive_mapper_from_item(object)
    end
  end

  context 'for array-like objects' do
    let(:object) { [Soy.new] }

    it 'should call derive_mapper_for_item' do
      stub(policy).derive_mapper_from_collection(object) { SoyCollectionMapper }
      policy.derive_mapper_from_object(object)
      expect(policy).to have_received.derive_mapper_from_collection(object)
    end
  end

  context 'mapper_for options set' do
    let(:object) { Soy.new }
    let(:options) { {mapper_rules: {WildSoy => MyMappers::SoyMapper, Soy => MyMappers::WheatMapper}} }
    subject(:policy) { described_class.new(options) }

    it 'should use the mapping' do
      expect(policy.derive_mapper_from_object(object)).to be MyMappers::WheatMapper
    end
  end
end
