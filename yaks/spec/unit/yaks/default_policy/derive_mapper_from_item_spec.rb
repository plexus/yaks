RSpec.describe Yaks::DefaultPolicy, '#derive_mapper_from_item' do
  subject(:policy) { described_class.new(options) }

  let(:options) { {} }

  it 'should use const_get with second argument set to false' do
    stub(Object).const_get(any_args) { SoyMapper }
    policy.derive_mapper_from_item(Soy.new)
    expect(Object).to have_received.const_get("SoyMapper", false)
  end

  context 'at top level' do
    it 'should derive it by name' do
      expect(policy.derive_mapper_from_item(Soy.new)).to be SoyMapper
    end

    it 'should look for parent class if not found' do
      expect(policy.derive_mapper_from_item(WildSoy.new)).to be SoyMapper
    end

    context 'with namespace option set' do
      let(:options) { {namespace: MyMappers} }

      it 'should look inside the namespace' do
        expect(policy.derive_mapper_from_item(Soy.new)).to be MyMappers::SoyMapper
      end

      it 'should look for its parent class mapper in the namespace if not found' do
        expect(policy.derive_mapper_from_item(WildSoy.new)).to be MyMappers::SoyMapper
      end
    end
  end

  context 'inside a module' do
    it 'should look inside the module' do
      expect(policy.derive_mapper_from_item(Grain::Soy.new)).to be Grain::SoyMapper
    end

    it 'should look for its parent class mapper in the module if not found' do
      expect(policy.derive_mapper_from_item(Grain::WildSoy.new)).to be Grain::SoyMapper
    end

    context 'no mapper defined in module' do
      it 'should look for mapper outside module' do
        expect(policy.derive_mapper_from_item(Grain::Wheat.new)).to be WheatMapper
      end

      it 'should look for its parent class mapper outside module' do
        expect(policy.derive_mapper_from_item(Grain::Durum.new)).to be WheatMapper
      end
    end

    context 'with namespace option set' do
      let(:options) { {namespace: MyMappers} }

      it 'should look inside the module' do
        expect(policy.derive_mapper_from_item(Grain::Soy.new)).to be MyMappers::Grain::SoyMapper
      end

      it 'should look for its parent class mapper if not found' do
        expect(policy.derive_mapper_from_item(Grain::WildSoy.new)).to be MyMappers::Grain::SoyMapper
      end

      context 'no mapper defined in module' do
        it 'should look for mapper in namespace top level' do
          expect(policy.derive_mapper_from_item(Grain::Wheat.new)).to be MyMappers::WheatMapper
        end

        it 'should look for its parent mapper in namespace top level' do
          expect(policy.derive_mapper_from_item(Grain::Durum.new)).to be MyMappers::WheatMapper
        end
      end
    end

    context 'deeply nested module' do
      it 'should look inside the module' do
        expect(policy.derive_mapper_from_item(Grain::Dry::Soy.new)).to be Grain::Dry::SoyMapper
      end
    end
  end

  context 'when no mapper is found' do
    it 'should give a nice message' do
      expect do
        policy.derive_mapper_from_item(Namespace::Nested::Mung.new)
      end.to raise_error /Failed to find a mapper for #<Namespace::Nested::Mung:0x\h+>. Did you mean to implement MungMapper\?/
    end
  end
end
