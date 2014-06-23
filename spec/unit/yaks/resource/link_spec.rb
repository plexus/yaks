require 'spec_helper'

RSpec.describe Yaks::Resource::Link do
  subject(:link) { described_class.new(rel, uri, options) }
  let(:rel)      { :foo_rel }
  let(:uri)      { 'http://api.example.org/rel/foo' }
  let(:options)  { {name: 'jimmy', title: 'mr. spectacular' } }

  its(:rel)     { should eql :foo_rel }
  its(:uri)     { should eql 'http://api.example.org/rel/foo' }
  its(:options) { should eql(name: 'jimmy', title: 'mr. spectacular') }

  its(:name)       { should eql('jimmy') }
  its(:title)      { should eql('mr. spectacular') }
  its(:templated?) { should be false }

  context 'with explicit templated option' do
    let(:options) { super().merge(templated: true) }
    its(:templated?) { should be true }
  end
end
