RSpec.describe Yaks::Config do
  include_context 'fixtures'

  def self.configure(&blk)
    subject(:config) { Yaks::ConfigBuilder.create(&blk) }
  end

  describe '#initialize' do
    context 'defaults' do
      configure {}

      its(:default_format)      { should equal :hal }
      its(:policy_class)        { should <= Yaks::DefaultPolicy }
      its(:primitivize)         { should be_a Yaks::Primitivize }
      its(:serializers)         { should eql(Yaks::Serializer.all)  }
      its(:hooks)               { should eql([])  }
      its(:format_options_hash) { should eql({})}
    end
  end

  describe '#default_format' do
    configure do
      default_format :json_api
    end

    its(:default_format) { should equal :json_api }
  end

  describe '#policy_class' do
    MyPolicy = Struct.new(:options)
    configure do
      policy_class MyPolicy
    end

    its(:policy_class) { should equal MyPolicy }
    its(:policy)       { should be_a MyPolicy  }
  end

  describe '#rel_template' do
    configure do
      mapper_namespace Object
      rel_template 'http://rel/foo'
    end

    its(:policy_options) { should eql(namespace: Object, rel_template: 'http://rel/foo') }
  end

  describe '#mapper_for' do
    let(:expected_options) do
      {
        namespace: Object,
        mapper_rules: {
          home: HomeMapper,
          Soy => MyMappers::WheatMapper
        }
      }
    end
    configure do
      mapper_namespace Object
      mapper_for Soy, MyMappers::WheatMapper
      mapper_for :home, HomeMapper
    end

    its(:policy_options) { should eql(expected_options) }
  end

  describe '#format_options' do
    configure do
      format_options :hal, plural_links: [:self, :profile]
      format_options :collection_json, template: :template_form_name
    end

    it 'should set format options' do
      expect(config.format_options_hash[:hal]).to eql(plural_links: [:self, :profile])
    end
  end

  describe '#json_serializer' do
    configure do
      json_serializer(&:upcase)
    end

    specify do
      expect(config.serializers[:json].call('foo')).to eql "FOO"
    end
  end

  describe '#map_to_primitive' do
    configure do
      map_to_primitive Date do |date|
        date.strftime("%Y-%m")
      end
    end

    it 'registers how to handle a primitive type' do
      expect(config.primitivize.call(Date.new(2015, 10))).to eql "2015-10"
    end

    it 'should not change the existing primitize instance' do
      old_prim = config.primitivize
      config.map_to_primitive Date do |date|
        date.strftime("%m-%Y")
      end
      expect(old_prim.call(Date.new(2015, 10))).to eql "2015-10"
    end
  end

  describe '#mapper_namespace' do
    configure do
      rel_template '/foo/{rel}'
      mapper_namespace Yaks::Mapper
    end

    it 'configures the policy to look in the given namespace' do
      expect(config.policy.options[:namespace]).to eql Yaks::Mapper
    end

    it 'should not overwrite other options' do
      expect(config.policy.options[:rel_template]).to eql '/foo/{rel}'
    end
  end

  describe '#policy' do
    PolicyClass = Class.new do
      include Attribs.new(:namespace)
    end

    configure do
      policy_class PolicyClass
      mapper_namespace Yaks::Mapper
    end

    it 'returns an instantiated policy' do
      expect(config.policy).to eql PolicyClass.new(namespace: Yaks::Mapper)
    end
  end

  describe '#derive_mapper_from_object' do
    configure { }
    let(:object) { Pet.new(id: 7, name: 'fifi', species: 'cat') }
    subject do
      config.derive_mapper_from_object do |object|
        mapper_class = super(object)
        Object.const_get("Great#{mapper_class.name}")
      end
    end

    its(:policy_class) { should <= Yaks::DefaultPolicy }

    it 'should override the policy method' do
      expect(subject.policy.derive_mapper_from_object(object)).to be GreatPetMapper
    end
  end

  describe '#derive_mapper_from_item' do
    configure { }
    let(:object) { Pet.new(id: 7, name: 'fifi', species: 'cat') }
    subject do
      config.derive_mapper_from_item do |object|
        mapper_class = super(object)
        Object.const_get("Great#{mapper_class.name}")
      end
    end

    its(:policy_class) { should <= Yaks::DefaultPolicy }

    it 'should override the policy method' do
      expect(subject.policy.derive_mapper_from_item(object)).to be GreatPetMapper
      expect(subject.policy.derive_mapper_from_object(object)).to be GreatPetMapper
    end
  end

  describe '#derive_mapper_from_collection' do
    configure { }
    let(:object) { [Pet.new(id: 7, name: 'fifi', species: 'cat')] }
    subject do
      config.derive_mapper_from_collection do |object|
        mapper_class_name = super(object).name.split('::').last
        Object.const_get("GreatPet#{mapper_class_name}")
      end
    end

    its(:policy_class) { should <= Yaks::DefaultPolicy }

    it 'should override the policy method' do
      expect(subject.policy.derive_mapper_from_collection(object)).to be GreatPetCollectionMapper
      expect(subject.policy.derive_mapper_from_object(object)).to be GreatPetCollectionMapper
    end
  end

  describe '#call' do
    configure do
      rel_template 'http://api.mysuperfriends.com/{rel}'
      format_options :hal, plural_links: [:copyright]
      skip :serialize
    end

    specify do
      expect(config.call(john)).to eql(load_json_fixture 'john.hal')
    end
  end

  describe '#map' do
    configure {}

    it 'only performs the mapping stage' do
      expect(config.map(wassup))
        .to eql Yaks::Resource.new(
                  type: "pet",
                  attributes: {id: 3, name: "wassup", species: "cat"}
                )
    end
  end

  describe '#read' do
    configure {
      default_format :json_api
    }

    it 'invokes the reader for the given format' do
      expect(config.read('{"data": [{"type": "pets",
                                     "id": 3,
                                     "name": "wassup",
                                     "species": "cat"}]}').members.first)
        .to eql Yaks::Resource.new(
                  type: "pet",
                  attributes: {id: 3, name: "wassup", species: "cat"}
                )
    end
  end

  describe '#format' do
    configure {
      default_format :hal
    }

    it 'invokes the formatter on a resource' do
      expect(config.format(Yaks::Resource.new(attributes: {shape: "round"})))
        .to eql("shape" => "round")
    end
  end

  describe '#runner' do
    configure {}

    it 'provides a Yaks::Runner' do
      expect(config.runner(:foo, bar: 1))
        .to eql Yaks::Runner.new(config: config, object: :foo, options: {bar: 1})
    end
  end

  describe '#serializer' do
    configure do
      serializer(:foo) {|x| x.upcase.reverse }
    end

    it 'registers a serializer for a given type' do
      expect(config.serializers[:foo].call('bar')).to eql 'RAB'
    end

    it 'should keep existing serializers' do
      expect(config.serializers[:json].call([:foo, :bar], {})).to eql %{[\n  "foo",\n  "bar"\n]}
    end
  end
end
