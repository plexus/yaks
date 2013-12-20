require 'spec_helper'

describe Yaks::Mapper::Link do
  subject(:link) { described_class.new(rel, template) }

  let(:rel) { :next }
  let(:template) { '/foo/bar/{x}/{y}' }

  its(:variables) { should eq ['x', 'y'] }
  its(:uri_template) { should eq URITemplate.new(template) }

  it 'should expand the template' do
    expect(link.expand(:x => 3, :y => 'foo')).to eq '/foo/bar/3/foo'
  end
end
