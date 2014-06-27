require 'spec_helper'

describe Yaks::DefaultPolicy do
  subject(:policy) { described_class.new(options) }

  let(:options) { {} }

  describe '#derive_mapper_from_object' do
    class SoyMapper ; end
    class Soy ; end
    class Wheat ; end

    context 'for a single instance' do
      it 'should derive it by name' do
        expect(policy.derive_mapper_from_object(Soy.new)).to be SoyMapper
      end

      module MyMappers
        class SoyMapper ; end
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

      class SoyCollectionMapper ; end

      it 'should find the mapper based on naming' do
        expect(policy.derive_mapper_from_object([Soy.new])).to be SoyCollectionMapper
      end

      module Namespace
        class CollectionMapper ; end
      end

      context 'if no collection mapper with a similar name is defined' do
        let(:options) { {namespace: Namespace} }

        it 'should look for a CollectionMapper in the namespace' do
          expect(policy.derive_mapper_from_object([Wheat.new])).to be Namespace::CollectionMapper
        end
      end
    end
  end
end
