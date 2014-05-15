require 'spec_helper'

describe Yaks::Mapper::Link do
  include_context 'shorthands'

  subject(:link) { described_class.new(rel, template, options) }

  let(:rel) { :next }
  let(:template) { '/foo/bar/{x}/{y}' }
  let(:options) { {} }
  its(:template_variables) { should eq ['x', 'y'] }
  its(:uri_template) { should eq URITemplate.new(template) }

  describe 'expand_with' do
    it 'should look up expansion values through the provided callable' do
      expect(link.expand_with(->(var){ var.upcase })).to eq '/foo/bar/X/Y'
    end

    context 'with expansion turned off' do
      let(:options) { {expand: false} }

      it 'should keep the template in the response' do
        expect(link.expand_with(->{ })).to eq '/foo/bar/{x}/{y}'
      end

      its(:expand?) { should be_false }
    end

    context 'with a URI without expansion variables' do
      let(:template) { '/orders' }

      it 'should return the link as is' do
        expect(link.expand_with(->{ })).to eq '/orders'
      end
    end
  end

end
