RSpec.describe Yaks::Mapper::Association do
  include_context 'yaks context'

  let(:association_class) {
    Class.new(described_class) do
      def map_resource(_object, _context)
      end
    end
  }

  subject(:association) do
    association_class.new(
      name: name,
      item_mapper: mapper,
      rel: rel,
      href: href,
      link_if: link_if,
      if: self.if
    )
  end

  let(:name)              { :shoes          }
  let(:mapper)            { Yaks::Mapper    }
  let(:rel)               { Yaks::Undefined }
  let(:href)              { Yaks::Undefined }
  let(:link_if)           { Yaks::Undefined }
  let(:if)                { Yaks::Undefined }

  its(:name)        { should equal :shoes }
  its(:item_mapper) { should equal Yaks::Mapper }

  context 'with a minimal constructor' do
    subject(:association) { association_class.new(name: :foo) }

    its(:name)         { should be :foo }
    its(:item_mapper)  { should be Yaks::Undefined }
    its(:rel)          { should be Yaks::Undefined }
    its(:href)         { should be Yaks::Undefined }
    its(:link_if)      { should be Yaks::Undefined }
  end

  let(:parent_mapper_class) { Yaks::Mapper }
  let(:parent_mapper)       { parent_mapper_class.new(yaks_context) }

  describe '#add_to_resource' do
    let(:object) { fake(shoes: []) }
    let(:rel)    { 'rel:shoes' }

    before do
      parent_mapper.call(object)
      stub(association).map_resource(any_args) { Yaks::Resource.new }
    end

    it 'should delegate to AssociationMapper' do
      expect(association.add_to_resource(Yaks::Resource.new, parent_mapper, yaks_context)).to eql Yaks::Resource.new(subresources: [Yaks::Resource.new(rels: ['rel:shoes'])])
    end

    context 'with a truthy condition' do
      let(:if)     { ->{ true } }

      it 'should add the association' do
        expect(association.add_to_resource(Yaks::Resource.new, parent_mapper, yaks_context).subresources.length).to be 1
      end
    end

    context 'without a condition' do
      it 'should add the association' do
        expect(association.add_to_resource(Yaks::Resource.new, parent_mapper, yaks_context).subresources.length).to be 1
      end
    end

    context 'with a falsey condition' do
      let(:if)     { ->{ false } }

      it 'should not add the association' do
        expect(association.add_to_resource(Yaks::Resource.new, parent_mapper, yaks_context).subresources.length).to be 0
      end
    end
  end

  describe '#render_as_link?' do
    let(:href)     { '/foo/{bar}/baz' }
    let(:link_if)  { -> { env.fetch('env_entry') == 123 } }
    let(:rack_env) { { 'env_entry' => 123 } }

    let(:render_as_link?) { association.render_as_link?(parent_mapper) }

    context 'when evaluating to true' do
      it 'should resolve :link_if in the context of the mapper' do
        expect(render_as_link?).to be true
      end
    end

    context 'when evaluating to false' do
      let(:rack_env) { { 'env_entry' => 0 } }

      it 'should resolve :link_if in the context of the mapper' do
        expect(render_as_link?).to be false
      end
    end

    context 'with an Undefined href' do
      let(:href) { Yaks::Undefined }

      it 'should return falsey' do
        expect(render_as_link?).to be_falsey
      end
    end

    context 'with an Undefined link_if' do
      let(:link_if) { Yaks::Undefined }

      it 'should return falsey' do
        expect(render_as_link?).to be_falsey
      end
    end
  end

  describe '#map_rel' do
    let(:association_rel) { association.map_rel(policy) }

    context 'with a rel specified' do
      let(:rel) { 'http://api.com/rels/shoes' }

      it 'should use the specified rel' do
        expect(association_rel).to eql 'http://api.com/rels/shoes'
      end
    end

    context 'without a rel specified' do
      before do
        stub(policy).derive_rel_from_association(association) {
          'http://api.com/rel/derived'
        }
      end

      it 'should infer a rel based on policy' do
        expect(association_rel).to eql 'http://api.com/rel/derived'
      end
    end
  end

  describe '#resolve_association_mapper' do
    context 'with a specified mapper' do
      let(:mapper) { :a_specific_mapper_class }

      it 'should return the mapper' do
        expect(association.resolve_association_mapper(nil)).to equal :a_specific_mapper_class
      end
    end

    context 'with the mapper undefined' do
      let(:mapper) { Yaks::Undefined }

      before do
        stub(policy).derive_mapper_from_association(association) {
          :a_derived_mapper_class
        }
      end

      it 'should derive a mapper based on policy' do
        expect(association.resolve_association_mapper(policy)).to equal :a_derived_mapper_class
      end
    end
  end

  describe '.create' do
    it 'should take a name' do
      expect(association_class.create(:foo).name).to be :foo
    end

    it 'should optionally take a mapper' do
      expect(association_class.create(:foo, mapper: :bar).item_mapper).to be :bar
    end

    it 'should take other options' do
      expect(association_class.create(:foo, mapper: :bar, href: 'xxx').href).to eql 'xxx'
    end

    it 'should respect attribute defaults' do
      expect(association_class.create(:foo, href: 'xxx').item_mapper).to be Yaks::Undefined
    end

    it 'should not munge the options hash' do
      opts  = {mapper: :foo}
      association_class.create(:foo, opts)
      expect(opts).to eql(mapper: :foo)
    end
  end
end
