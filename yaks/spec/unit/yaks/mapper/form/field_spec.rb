require 'spec_helper'

RSpec.describe Yaks::Mapper::Form::Field do
  include_context 'yaks context'

  let(:field)   { described_class.new( full_args ) }
  let(:name)      { :the_field }
  let(:full_args) { {name: name}.merge(args) }
  let(:args) {
    {
      label: 'a label',
      type: 'text',
      value: 'hello'
    }
  }

  let(:mapper) { Yaks::Mapper.new(yaks_context) }

  describe '.create' do
    it 'can take all args as a hash' do
      expect(described_class.create(full_args)).to eql described_class.new(full_args)
    end

    it 'can take a name as a positional arg' do
      expect(described_class.create(name, args)).to eql described_class.new(full_args)
    end

    it 'can take only a name' do
      expect(described_class.create(name)).to eql described_class.new(name: :the_field)
    end
  end

  describe '#to_resource_field' do
    it 'creates a Yaks::Resource::Form::Field with the same attributes' do
      expect(field.to_resource(mapper)).to eql Yaks::Resource::Form::Field.new(full_args)
    end
  end
end
