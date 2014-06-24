require 'spec_helper'

RSpec.describe Yaks::NullResource do
  subject(:null_resource) { described_class.new }

  its(:attributes)     { should eq Hash[] }
  its(:links)          { should eq [] }
  its(:subresources)   { should eq Hash[] }
  its(:collection?)    { should be false }
  its(:null_resource?) { should be true }

  it { should respond_to :[] }

  its(:type) { should be_nil }

  describe '#each' do
    its(:each)         { should be_a Enumerator }

    it 'should not yield anything' do
      null_resource.each { fail }
    end
  end

  it 'should contain nothing' do
    expect( null_resource[:key] ).to be_nil
  end

  context 'when a collection' do
    subject(:null_resource) { described_class.new( collection: true ) }
    its(:collection?) { should be true }
  end
end
