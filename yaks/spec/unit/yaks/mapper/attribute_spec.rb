RSpec.describe Yaks::Mapper::Attribute do
  include_context 'yaks context'

  let(:attribute_with_block) { described_class.create(:the_name) { "Alice" } }
    subject(:attribute) { described_class.create(:the_name) }
  fake(:mapper)

  before do
    stub(mapper).load_attribute(:the_name) { 123 }
    stub(mapper).object { fake(name: "Bob") }
  end

  describe ".create" do
    its(:name) { should be :the_name }
    its(:block) { should be_nil }

    it "should accept two parameter" do
      expect{described_class.create(:the_name, {})}.not_to raise_error()
    end

    context "with block" do
      subject(:attribute) { attribute_with_block }

      its(:block) { should_not be_nil }

      it "should store the given block" do
        expect(subject.block.call).to eq("Alice")
      end
    end

    describe "options" do

      let(:object) { Struct.new(:x, :y, :returns_nil).new(3, 4, nil) }

      let(:mapper_class) do
        Class.new(Yaks::Mapper) do
          type 'foo'
        end
      end

      let(:mapper) do
        mapper_class.new(yaks_context).tap do |mapper|
          mapper.call(object) # set @object
        end
      end

      subject(:attribute) { described_class.create(:the_name, options) }

      context 'with :if defined and resolving to false' do

        let(:options) { {if: ->{ false }} }

        it 'should not render the attribute' do
          expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context)).not_to eql(
            Yaks::Resource.new(attributes: {the_name: 123})
          )
        end
      end

      context 'with :if defined and resolving to true' do
        let(:options) { {if: ->{ true }} }

        it 'should render the attribute' do
          expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context)).to eql(
            Yaks::Resource.new(attributes: {the_name: 123})
          )
        end
      end
    end

  end

  describe "#add_to_resource" do

    let(:options) { {if: ->{ true }} }
    let(:options_false) { {if: ->{ 0 == 1 }} }
    let(:attribute_with_block_and_false_options) {described_class.create(:the_name,options_false) { "Alice" } }
    let(:attribute_with_block_and_options) { described_class.create(:the_name,options) { "Alice" } }



    it "should add itself to a resource based on a lookup" do
      expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
        .to eql(Yaks::Resource.new(attributes: {the_name: 123}))
    end

    context "when the attribute has a block and true options" do
      subject(:attribute) { attribute_with_block_and_options }

      it "should add itself to a resource with the block value" do
        expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
          .to eql(Yaks::Resource.new(attributes: {the_name: "Alice"}))
      end

      
    end

    context "when the attribute has a block and false options" do
      subject(:attribute) { attribute_with_block_and_false_options }

      it "should not add itself to a resource with the block value" do
        expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
          .not_to eql(Yaks::Resource.new(attributes: {the_name: "Alice"}))
      end

      
    end

    context "when the attribute has a block" do
      subject(:attribute) { attribute_with_block }

      it "should add itself to a resource with the block value" do
        expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
          .to eql(Yaks::Resource.new(attributes: {the_name: "Alice"}))
      end

      context "using the mapper context" do
        let(:attribute) { described_class.create(:the_name) { object.name } }

        it "should add itself to a resource with the block value" do
          expect(attribute.add_to_resource(Yaks::Resource.new, mapper, yaks_context))
            .to eql(Yaks::Resource.new(attributes: {the_name: "Bob"}))
        end
      end
    end
  end
end
