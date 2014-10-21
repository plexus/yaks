require 'spec_helper'

RSpec.describe Yaks::Config::DSL do
  subject!(:dsl) { described_class.new(yaks_config, &config_block) }

  let(:yaks_config)  { Yaks::Config.new }
  let(:config_block) { nil }

  def self.configure(&blk)
    let(:config_block) { blk }
  end

  describe '#initialize' do
    its(:config) { should equal yaks_config }

    it 'should set a default policy' do
      expect(yaks_config.policy_class.new).to be_a_kind_of Yaks::DefaultPolicy
    end

    it 'should execute the given block in instance scope' do
      dsl = described_class.new(yaks_config) do
        @config = :foo
      end
      expect(dsl.config).to be :foo
    end

    describe 'policy redefinitions' do
      configure do
        derive_type_from_mapper_class do |mapper_class|
          :inside_redefined_policy_method
        end
      end

      it 'should delegate and redefine' do
        expect(yaks_config.policy.derive_type_from_mapper_class(nil)).to be :inside_redefined_policy_method
      end

      it 'should not change the original class definition' do
        expect(Yaks::DefaultPolicy.new.derive_type_from_mapper_class(fake(name: 'FooMapper'))).to eql 'foo'
      end
    end
  end

  describe '#format_options' do
    configure { format_options :hal, singular_link: [:self] }
    specify   { expect(yaks_config.format_options[:hal]).to eq(singular_link: [:self]) }
  end

  describe '#default_format' do
    configure { default_format :json_api }
    specify   { expect(yaks_config.default_format).to be :json_api }
  end

  describe '#policy' do
    configure { policy 'MyPolicyClass' }
    specify   { expect(yaks_config.policy_class).to eql 'MyPolicyClass' }
  end

  describe '#rel_template' do
    configure { rel_template 'rels:{rel}' }
    specify   { expect(yaks_config.policy_options[:rel_template]).to eql 'rels:{rel}' }
  end

  describe '#serializer' do
    configure { serializer(:json) { |i| "foo #{i}" } }
    specify   { expect(yaks_config.serializers[:json].call(7)).to eql 'foo 7' }
  end

  describe '#json_serializer' do
    configure { json_serializer { |i| "foo #{i}" } }
    specify   { expect(yaks_config.serializers[:json].call(7)).to eql 'foo 7' }
  end

  describe '#mapper_namespace' do
    configure { mapper_namespace RSpec }
    specify   { expect(yaks_config.policy_options[:namespace]).to eql RSpec }
  end

  describe '#map_to_primitive' do
    Foo = Class.new do
      attr_reader :foo

      def initialize(foo)
        @foo = foo
      end
    end

    configure { map_to_primitive(Foo) {|c| c.foo } }
    specify   { expect(yaks_config.primitivize.call({:abc => Foo.new('hello')})).to eql 'abc' => 'hello' }
  end

end
