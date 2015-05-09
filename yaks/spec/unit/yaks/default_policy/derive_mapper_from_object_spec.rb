RSpec.describe Yaks::DefaultPolicy, '#derive_mapper_from_object' do
  subject(:policy) { described_class.new }

  context 'for a single instance' do
    let(:object) { Soy.new }

    it 'should call derive_mapper_for_single_object' do
      stub(policy).derive_mapper_from_single_object(object) { SoyMapper }
      policy.derive_mapper_from_object(object)
      expect(policy).to have_received.derive_mapper_from_single_object(object)
    end
  end

  context 'for array-like objects' do
    let(:object) { [Soy.new] }

    it 'should call derive_mapper_for_single_object' do
      stub(policy).derive_mapper_from_collection(object) { SoyCollectionMapper }
      policy.derive_mapper_from_object(object)
      expect(policy).to have_received.derive_mapper_from_collection(object)
    end
  end
end
