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
    subject(:policy) { described_class.new(options) }

    context 'when mapping a class' do
      let(:options) { {mapper_rules: {home: HomeMapper, Soy => MyMappers::WheatMapper}} }

      it 'should use the mapping' do
        expect(policy.derive_mapper_from_object(Soy.new)).to be MyMappers::WheatMapper
      end
    end

    context 'when mapping a symbol' do
      let(:options) { {mapper_rules: {soy: SoyMapper}} }

      it 'should use the mapping' do
        expect(policy.derive_mapper_from_object(:soy)).to be SoyMapper
      end
    end

    context 'when mapping a lambda' do
      let(:user) { fake(logged_in?: true) }
      let(:options) { {mapper_rules: {->(user){ user.logged_in? } => SoyMapper}} }

      it 'should use the mapping' do
        expect(policy.derive_mapper_from_object(user)).to be SoyMapper
      end
    end
  end
end
