RSpec.describe Yaks::Resource do
  subject(:resource) { described_class.new(init_opts) }
  let(:init_opts) { {} }

  describe '#initialize' do
    context 'with a zero-arg constructor' do
      subject(:resource) { described_class.new }

      its(:type)           { should be_nil }
      its(:attributes)     { should eql({}) }
      its(:links)          { should eql [] }
      its(:subresources)   { should eql [] }
      its(:self_link)      { should be_nil }
      its(:null_resource?) { should be false }
    end

    it 'should verify subresources is an array' do
      expect { Yaks::Resource.new(subresources: { '/rel/comments' => []}) }
        .to raise_exception /comments/
    end

    it 'should verify subresources is an array' do
      expect { Yaks::Resource.new(subresources: []) }
        .to_not raise_exception
    end

    it 'should work without args' do
      expect( Yaks::Resource.new ).to be_a Yaks::Resource
    end

    it 'should take defaults when no args are passed' do
      expect( Yaks::Resource.new.rels ).to eq []
    end
  end

  describe "#[]" do
    it "should access attributes" do
      expect(described_class.new(attributes: {foo: :bar})[:foo]).to eql :bar
    end
  end

  describe '#find_form' do
    it 'should find a form by name' do
      expect(resource
              .add_form(Yaks::Resource::Form.new(name: :a_form))
              .add_form(Yaks::Resource::Form.new(name: :b_form))
              .find_form(:b_form))
        .to eq Yaks::Resource::Form.new(name: :b_form)
    end
  end

  describe "#seq" do
    it "should provide an enumerable that yields this resource once" do
      expect(resource.seq.each.to_a).to eql [resource]
    end
  end

  describe '#self_link' do
    let(:init_opts) {
      { links:
        [
          Yaks::Resource::Link.new(rel: :self, uri: 'foo'),
          Yaks::Resource::Link.new(rel: :self, uri: 'bar'),
          Yaks::Resource::Link.new(rel: :profile, uri: 'baz')
        ]
      }
    }
    it 'should return the last self link' do
      expect(resource.self_link).to eql Yaks::Resource::Link.new(rel: :self, uri: 'bar')
    end
  end

  describe "#collection?" do
    it "should be false" do
      expect(resource.collection?).to be false
    end
  end

  describe "#null_resource?" do
    it "should be false" do
      expect(resource.null_resource?).to be false
    end
  end

  describe '#add_rel' do
    it 'should add to the rels' do
      expect(resource.add_rel(:foo).add_rel(:bar))
        .to eql Yaks::Resource.new(rels: [:foo, :bar])
    end
  end

  describe "#add_link" do
    let(:init_opts) {{
      links: [Yaks::Resource::Link.new(rel: :next, uri: '/next')]
    }}

    it "should append to the links list" do
      expect(resource.add_link(Yaks::Resource::Link.new(rel: :previous, uri: '/previous')))
        .to eql Yaks::Resource.new(links: [
          Yaks::Resource::Link.new(rel: :next, uri: '/next'),
          Yaks::Resource::Link.new(rel: :previous, uri: '/previous')
        ])
    end
  end

  describe '#add_form' do
    it 'should append to the forms' do
      expect(resource.add_form(Yaks::Resource::Form.new(name: :a_form)))
        .to eq Yaks::Resource.new(forms: [Yaks::Resource::Form.new(name: :a_form)])
    end
  end

  describe "#add_subresource" do
    let(:init_opts) {{
      subresources: [Yaks::Resource.new(attributes: {foo: 1})]
    }}
    it "should append to the subresources list" do
      expect(resource.add_subresource(Yaks::Resource.new(attributes: {bar: 2})))
        .to eql Yaks::Resource.new(
          subresources: [
            Yaks::Resource.new(attributes: {foo: 1}),
            Yaks::Resource.new(attributes: {bar: 2})
          ]
        )
    end
  end

  describe '#members' do
    it 'should raise unsupported operation error' do
      expect { resource.members }.to raise_error(
        Yaks::UnsupportedOperationError, "Only Yaks::CollectionResource has members"
      )
    end
  end

  describe "#merge_attributes" do
    let(:init_opts) {{ attributes: {foo: 1, bar: 2} }}
    it "should merge attributes into any existing attributes" do
      expect(resource.merge_attributes(bar: 3, baz: 4))
        .to eql Yaks::Resource.new(attributes: {foo: 1, bar: 3, baz: 4})
    end
  end

  describe '#with_collection' do
    it 'should be a no-op' do
      expect(described_class.new.with_collection([:foo])).to eql Yaks::Resource.new
    end
  end
end
