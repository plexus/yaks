require 'spec_helper'

describe Yaks::Resource do
  include_context 'shorthands'

  let(:object) { described_class.new(attributes, links, subresources) }
  let(:attributes) { {} }
  let(:links) { [] }
  let(:subresources) { {} }

  describe '#uri' do
    subject { object.uri }

    context 'without a self link' do
      it { should be_nil }
    end

    context 'with a self link' do
      let(:links) { [ resource_link[:self, '/foo/this_is_me/7'] ] }
      it { should eq '/foo/this_is_me/7' }
    end
  end
end
