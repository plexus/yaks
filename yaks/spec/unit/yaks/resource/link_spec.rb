RSpec.describe Yaks::Resource::Link do
  subject(:link) { described_class.new(rel: rel, uri: uri, options: options) }

  let(:rel)      { :foo_rel }
  let(:uri)      { 'http://api.example.org/rel/foo' }
  let(:options)  { {title: 'mr. spectacular'} }

  its(:rel)     { should eql :foo_rel }
  its(:uri)     { should eql 'http://api.example.org/rel/foo' }
  its(:options) { should eql(title: 'mr. spectacular') }

  describe '#title' do
    its(:title)      { should eql('mr. spectacular') }
  end

  describe '#templated?' do
    its(:templated?) { should be false }

    context 'with explicit templated option' do
      let(:options) { super().merge(templated: true) }
      its(:templated?) { should be true }
    end
  end

  describe '#rel?' do
    let(:rel) { "/rels/foo" }

    it 'should be true if the rel matches' do
      expect(link.rel?("/rels/foo")).to be true
    end

    it 'should be false if the rel does not match' do
      expect(link.rel?(:foo)).to be false
    end
  end
end
