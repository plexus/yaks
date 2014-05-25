require 'spec_helper'

describe Yaks::Resource do
  subject(:resource) { described_class.new(init_opts) }
  let(:init_opts) { {} }

  its(:type)         { should be_nil }
  its(:attributes)   { should eql({}) }
  its(:links)        { should eql [] }
  its(:subresources) { should eql({}) }

  context 'with attributes' do
    let(:init_opts) { { attributes: {name: 'Arne', age: 31} } }

    it 'should delegate [] to attribute access' do
      expect(resource[:name]).to eql 'Arne'
    end
  end
end
