require 'spec_helper'

describe Yaks::Mapper::Association do
  include Yaks::FP

  let(:name)              { :shoes       }
  let(:mapper)            { Yaks::Mapper }
  let(:rel)               { Yaks::Undefined }
  let(:collection_mapper) { Yaks::Undefined }
  let(:parent_mapper)     { Yaks::Undefined }
  let(:map_resource)      { Yaks::FP::I }
  let(:lookup)            { Yaks::FP::I }
  let(:policy)            { Yaks::DefaultPolicy.new }

  its(:name) { should equal :shoes }

  subject(:association) do
    described_class
      .new(name, mapper, rel, collection_mapper)
      .tap &send_with_args(:stub, :map_resource, &map_resource)
  end

  describe '#map_to_resource_pair' do
    subject(:resource_pair) do
      association.map_to_resource_pair(parent_mapper, lookup, policy)
    end

    context 'with a rel specified' do
      let(:rel) { 'http://api.com/rels/shoes' }

      it 'should use the specified rel' do
        expect(resource_pair[0]).to eql 'http://api.com/rels/shoes'
      end
    end

    context 'without a rel specified' do
      it 'should infer a rel based on policy' do
        expect(policy)
          .to receive(:derive_rel_from_association)
          .with(parent_mapper, association)
          .and_return('http://api.com/rel/derived')

        expect(resource_pair[0]).to eql 'http://api.com/rel/derived'
      end
    end

    let(:lookup) { { shoes: 'unmapped resource' } }

    it 'should delegate to the map_resource method, to be overridden in child classes' do
      expect(association)
        .to receive(:map_resource)
        .with('unmapped resource', policy)
        .and_return('mapped resource')

      expect(resource_pair[1]).to eql 'mapped resource'
    end
  end

  describe '#association_mapper' do
    context 'with a specified mapper' do
      let(:mapper) { :a_specific_mapper_class }

      it 'should return the mapper' do
        expect(association.association_mapper(nil)).to equal :a_specific_mapper_class
      end
    end

    context 'with the mapper undefined' do
      let(:mapper) { Yaks::Undefined }

      it 'should derive a mapper based on policy' do
        expect(policy)
          .to receive(:derive_mapper_from_association)
          .with(association)
          .and_return(:a_derived_mapper_class)

        expect(association.association_mapper(policy)).to equal :a_derived_mapper_class
      end
    end
  end
end
