RSpec.describe Yaks::DefaultPolicy, '#derive_mapper_from_object' do
  subject(:policy) { described_class.new(options) }

  let(:options) { {} }

  it 'should use const_get with second argument set to false' do
    stub(Object).const_get(any_args) { SoyMapper }
    policy.derive_mapper_from_object(Soy.new)
    expect(Object).to have_received.const_get("SoyMapper", false)
  end

  context 'for a single instance' do
    context 'outside a module' do
      it 'should derive it by name' do
        expect(policy.derive_mapper_from_object(Soy.new)).to be SoyMapper
      end

      it 'should look for parent class if not found' do
        expect(policy.derive_mapper_from_object(WildSoy.new)).to be SoyMapper
      end

      context 'with namespace option set' do
        let(:options) { {namespace: MyMappers} }

        it 'should look inside the namespace' do
          expect(policy.derive_mapper_from_object(Soy.new)).to be MyMappers::SoyMapper
        end

        it 'should look for its parent class mapper in the namespace if not found' do
          expect(policy.derive_mapper_from_object(WildSoy.new)).to be MyMappers::SoyMapper
        end
      end
    end

    context 'inside a module' do
      it 'should look inside the module' do
        expect(policy.derive_mapper_from_object(Grain::Soy.new)).to be Grain::SoyMapper
      end

      it 'should look for its parent class mapper in the module if not found' do
        expect(policy.derive_mapper_from_object(Grain::WildSoy.new)).to be Grain::SoyMapper
      end

      context 'no mapper defined in module' do
        it 'should look for mapper outside module' do
          expect(policy.derive_mapper_from_object(Grain::Wheat.new)).to be WheatMapper
        end

        it 'should look for its parent class mapper outside module' do
          expect(policy.derive_mapper_from_object(Grain::Durum.new)).to be WheatMapper
        end
      end

      context 'with namespace option set' do
        let(:options) { {namespace: MyMappers} }

        it 'should look inside the module' do
          expect(policy.derive_mapper_from_object(Grain::Soy.new)).to be MyMappers::Grain::SoyMapper
        end

        it 'should look for its parent class mapper if not found' do
          expect(policy.derive_mapper_from_object(Grain::WildSoy.new)).to be MyMappers::Grain::SoyMapper
        end

        context 'no mapper defined in module' do
          it 'should look for mapper in namespace top level' do
            expect(policy.derive_mapper_from_object(Grain::Wheat.new)).to be MyMappers::WheatMapper
          end

          it 'should look for its parent mapper in namespace top level' do
            expect(policy.derive_mapper_from_object(Grain::Durum.new)).to be MyMappers::WheatMapper
          end
        end
      end

      context 'deeply nested module' do
        it 'should look inside the module' do
          expect(policy.derive_mapper_from_object(Grain::Dry::Soy.new)).to be Grain::Dry::SoyMapper
        end
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
        expect(policy.derive_mapper_from_object([WildSoy.new])).to be(
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
      expect do
        policy.derive_mapper_from_object([Namespace::Nested::Rye.new])
      end.to raise_error
    end
  end

  context 'when no mapper is found' do
    it 'should give a nice message' do
      expect do
        policy.derive_mapper_from_object(Namespace::Nested::Mung.new)
      end.to raise_error /Failed to find a mapper for #<Namespace::Nested::Mung:0x\h+>. Did you mean to implement MungMapper\?/
    end
  end
end
