require 'spec_helper'

RSpec.describe Yaks::Mapper::Control do
  let(:control)   { described_class.new( full_args ) }
  let(:name)      { :the_name }
  let(:full_args) { {name: name}.merge(args) }
  let(:args) {
    {
      action: '/foo',
      title: 'a title',
      method: 'PATCH',
      media_type: 'application/hal+json',
      fields: fields
    }
  }
  let(:fields) { [] }

  describe '.create' do
    it 'should create an instance, first arg is the name' do

      expect( described_class.create(name, args) ).to eql control
    end

    it 'should have a name of nil when ommitted' do
      expect(described_class.create.name).to be_nil
    end
  end

  describe '#add_to_resource' do
    let(:resource) { control.add_to_resource(Yaks::Resource.new, Yaks::Mapper.new(nil), nil) }

    it 'should add a control to the resource' do
      expect(resource.controls.length).to be 1
    end

    it 'should create a Yaks::Resource::Control with corresponding fields' do
      expect(resource.controls.first).to eql Yaks::Resource::Control.new( full_args )
    end

    context 'with fields' do
      let(:fields) {
        [
          Yaks::Mapper::Control::Field.new(
            name: 'field name',
            label: 'field label',
            type: 'text',
            value: 7
          )
        ]
      }

      it 'should map to Yaks::Resource::Control::Field instances' do
        expect(resource.controls.first.fields).to eql [
          Yaks::Resource::Control::Field.new(
            name: 'field name',
            label: 'field label',
            type: 'text',
            value: 7
          )
        ]
      end
    end
  end
end
