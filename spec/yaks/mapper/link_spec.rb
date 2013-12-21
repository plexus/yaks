require 'spec_helper'

describe Yaks::Mapper::Link do
  include_context 'shorthands'

  subject(:link) { described_class.new(rel, template, options) }

  let(:rel) { :next }
  let(:template) { '/foo/bar/{x}/{y}' }
  let(:options) { {} }
  its(:variables) { should eq ['x', 'y'] }
  its(:uri_template) { should eq URITemplate.new(template) }

  it 'should expand the template' do
    expect(link.expand(:x => 3, :y => 'foo')).to eq '/foo/bar/3/foo'
  end

  describe 'expand_with' do
    it 'should look up expansion values through the provided callable' do
      expect(link.expand_with(->(var){ var.upcase })).to eq resource_link[:next, '/foo/bar/X/Y']
    end

    context 'with expansion turned off' do
      let(:options) { {expand: false} }

      it 'should keep the template in the response' do
        expect(link.expand_with(->{ })).to eq resource_link[:next, '/foo/bar/{x}/{y}', templated: true]
      end

      its(:expand?) { should be_false }
    end

    context 'with a URI without expansion variables' do
      let(:template) { '/orders' }

      it 'should return the link as is' do
        expect(link.expand_with(->{ })).to eq resource_link[:next, '/orders', templated: true]
      end
    end
  end

end
