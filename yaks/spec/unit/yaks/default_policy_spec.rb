require 'spec_helper'

RSpec.describe Yaks::DefaultPolicy do
  subject(:policy) { described_class.new( options ) }

  let(:options) { {} }
  let(:association) { Yaks::Mapper::HasMany.create('shoes') }

  describe '#initialize' do
    it 'should work without arguments' do
      expect(described_class.new.options).to eql described_class::DEFAULTS
    end

    let(:options) { {foo: :bar} }

    it 'should merge default and given options' do
      expect(policy.options.values_at(:namespace, :foo)).to eql [Kernel, :bar]
    end
  end

  describe '#derive_type_from_mapper_class' do
    specify do
      expect(
        policy.derive_type_from_mapper_class(Namespace::RyeMapper)
      ).to eql 'rye'
    end
  end

  describe '#derive_type_from_collection' do
    specify do
      expect(
        policy.derive_type_from_collection([Soy.new])
      ).to eql 'soy'
    end

    specify do
      expect(
        policy.derive_type_from_collection([])
      ).to be_nil
    end
  end

  describe '#derive_mapper_from_association' do
    let(:options) { { namespace: Namespace } }

    it 'should derive using the singular association name, and look inside the namespace' do
      expect(policy.derive_mapper_from_association(association)).to be Namespace::ShoeMapper
    end
  end

  describe '#derive_rel_from_association' do
    it 'should expand the rel based on the association name' do
      expect(policy.derive_rel_from_association(association)).to eql 'rel:shoes'
    end
  end

  describe '#expand_rel' do
    let(:options) { { rel_template: 'http://foo/{?rel}' } }
    it 'should expand the given template' do
      expect(policy.expand_rel('rockets')).to eql 'http://foo/?rel=rockets'
    end
  end

end
