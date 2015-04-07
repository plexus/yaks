RSpec.describe Yaks::Mapper do
  include_context 'yaks context'

  subject(:mapper)   { mapper_class.new(yaks_context) }
  let(:resource)     { mapper.call(instance) }

  let(:mapper_class) { Class.new(Yaks::Mapper) { type 'foo' } }

  let(:instance) { fake(foo: 'hello', bar: 'world') }

  describe "#initialize" do
    it "should store the context" do
      expect(mapper.context).to equal yaks_context
    end
  end

  describe "#env" do
    its(:env) { should equal rack_env }
  end

  describe "#policy" do
    it "should pull it out of the context" do
      expect(mapper.policy).to equal policy
    end
  end

  describe '#call' do
    context 'with attributes' do
      before do
        mapper_class.attributes :foo, :bar
      end

      it 'should make the configured attributes available on the instance' do
        expect(mapper.attributes).to eq [
          Yaks::Mapper::Attribute.new(:foo),
          Yaks::Mapper::Attribute.new(:bar)
        ]
      end

      it 'should load them from the model' do
        expect(resource.attributes).to eq(foo: 'hello', bar: 'world')
      end

      context 'with attribute filtering' do
        before do
          mapper_class.class_eval do
            def attributes
              super.reject {|attr| attr.name == :foo}
            end
          end
        end

        it 'should only map the non-filtered attributes' do
          expect(resource.attributes).to eq(:bar => 'world')
        end
      end
    end

    context 'with links' do
      before do
        mapper_class.link :profile, 'http://foo/bar'
      end

      it 'should map the link' do
        expect(resource.links).to eq [
          Yaks::Resource::Link.new(rel: :profile, uri: 'http://foo/bar')
        ]
      end

      it 'should use the link in the resource' do
        expect(resource.links).to include Yaks::Resource::Link.new(rel: :profile, uri: 'http://foo/bar')
      end

      context 'with the same link rel defined multiple times' do
        before do
          mapper_class.class_eval do
            link(:self, 'http://foo/bam')
            link(:self, 'http://foo/baz')
            link(:self, 'http://foo/baq')
          end
        end

        it 'should map all the links' do
          expect(resource.links).to eq [
            Yaks::Resource::Link.new(rel: :profile, uri: 'http://foo/bar'),
            Yaks::Resource::Link.new(rel: :self, uri: 'http://foo/bam'),
            Yaks::Resource::Link.new(rel: :self, uri: 'http://foo/baz'),
            Yaks::Resource::Link.new(rel: :self, uri: 'http://foo/baq')
          ]
        end
      end
    end

    context 'with subresources' do
      let(:widget)   { fake(type: 'super_widget') }
      let(:instance) { fake(widget: widget) }
      let(:widget_mapper) { Class.new(Yaks::Mapper) { type 'widget' } }
      fake(:policy) { Yaks::DefaultPolicy }

      describe 'has_one' do
        let(:has_one_opts) do
          { mapper: widget_mapper,
            rel: 'http://foo.bar/rels/widgets' }
        end

        before do
          widget_mapper.attributes :type
          mapper_class.has_one(:widget, has_one_opts)
        end


        it 'should have the subresource in the resource' do
          expect(resource.subresources).to eq([Yaks::Resource.new(type: 'widget', attributes: {:type => 'super_widget'}, rels: ['http://foo.bar/rels/widgets'])])
        end

        context 'with explicit mapper and rel' do
          it 'should delegate to the given mapper' do
            expect(resource.subresources).to eq([
              Yaks::Resource.new(type: 'widget', attributes: {:type => 'super_widget'}, rels: ['http://foo.bar/rels/widgets'])
            ])
          end
        end

        context 'with unspecified mapper' do
          let(:has_one_opts) do
            { rel: 'http://foo.bar/rels/widgets' }
          end

          before do
            stub(policy).derive_mapper_from_association(mapper.associations.first) do
              widget_mapper
            end
          end

          it 'should derive the mapper based on policy' do
            expect(resource.subresources).to eq([
              Yaks::Resource.new(type: 'widget', attributes: {:type => 'super_widget'}, rels: ['http://foo.bar/rels/widgets'])
            ])
          end
        end

        context 'with unspecified rel' do
          let(:has_one_opts) do
            { mapper: widget_mapper }
          end

          before do
            stub(policy).derive_rel_from_association(mapper.associations.first) do
              'http://rel/rel'
            end
          end

          it 'should derive the rel based on policy' do
            expect(resource.subresources).to eq([
              Yaks::Resource.new(type: 'widget', attributes: {:type => 'super_widget'}, rels: ['http://rel/rel'])
            ])
          end
        end

        context 'with the association filtered out' do
          before do
            mapper_class.class_eval do
              def associations
                []
              end
            end
          end

          it 'should not map the resource' do
            expect(resource.subresources).to eq([])
          end
        end
      end
    end

    context 'when the mapper implements a method with the attribute name' do
      before do
        mapper_class.class_eval do
          attributes :fooattr, :bar

          def fooattr
            "#{object.foo} my friend"
          end
        end
      end

      it 'should get the attribute from the mapper' do
        expect(resource.attributes).to eq(fooattr: 'hello my friend', bar: 'world')
      end
    end

    context 'with a nil subject' do
      it 'should return a NullResource when the subject is nil' do
        expect(mapper.call(nil)).to be_a Yaks::NullResource
      end
    end

    context 'with a link generated by a method that returns nil' do
      before do
        mapper_class.class_eval do
          attributes :id
          link :bar_link, -> { link_generating_method }

          def link_generating_method
          end
        end
      end

      it 'should not render the link' do
        expect(mapper.call(fake(id: 123))).to eql Yaks::Resource.new(
          type: 'foo',
          attributes: {id: 123}
        )
      end
    end

    context 'with a form' do
      before do
        mapper_class.module_eval do
          form :foo_form do
            field :bar_field, label: 'a label', type: 'number', value: 7
          end
        end
      end

      it 'should render the form' do
        expect(mapper.call(fake))
          .to eql Yaks::Resource.new(
                    type: 'foo',
                    forms: [
                      Yaks::Resource::Form.new(
                        name: :foo_form,
                        fields: [
                          Yaks::Resource::Form::Field.new(
                            name: :bar_field,
                            label: 'a label',
                            type: 'number',
                            value: 7
                          )])])
      end
    end

    it "should optionally take a rack env" do
      expect { mapper.call(fake, {}) }.to_not raise_error
    end

  end # describe '#call'

  describe '.mapper_name' do
    context 'with a type configured' do
      it 'should use the type' do
        expect(mapper_class.mapper_name(policy)).to eql 'foo'
      end
    end

    context 'without a type configured' do
      let(:mapper_class) { PetMapper }

      it 'should infer the type from the name' do
        expect(mapper_class.mapper_name(policy)).to eql 'pet'
      end
    end
  end

  describe '#mapper_name' do
    context 'with a type configured' do
      it 'should use the type' do
        expect(mapper.mapper_name).to eql 'foo'
      end
    end

    context 'without a type configured' do
      let(:mapper_class) { PetMapper }

      it 'should infer the type from the name' do
        expect(mapper.mapper_name).to eql 'pet'
      end
    end
  end

  describe '#load_attribute' do
    context 'with the attribute defined as a method on the mapper' do
      it 'should call the local implementation' do
        def mapper.foo
          14
        end

        expect(mapper.load_attribute(:foo)).to eql 14
      end
    end

    context 'without a mapper method with the attribute name' do
      it 'should call the method on the object being mapped' do
        mapper.call(instance) # set @object
        expect(mapper.load_attribute(:foo)).to eql 'hello'
      end
    end
  end

  describe '#map_attributes' do
    let(:attribute) { fake('Attribute') }

    it 'should receive a context' do
      stub(attribute).add_to_resource(any_args) {|r,_,_| Yaks::Resource.new}

      mapper.config.attributes[0..-1] = [attribute]
      mapper.call(instance)

      expect(attribute).to have_received.add_to_resource(any(Yaks::Resource), mapper, yaks_context)
    end
  end

  shared_examples 'something that can be added to a resource' do
    it 'should receive a context' do
      stub(object).add_to_resource(any_args) {|r,_,_| Yaks::Resource.new}

      mapper.call(instance)

      expect(object).to have_received.add_to_resource(any(Yaks::Resource), mapper, yaks_context)
    end
  end

  describe '#map_links' do
    let(:object) { fake('Link') }
    before { mapper_class.config = mapper.config.append_to(:links, object) }
    it_should_behave_like 'something that can be added to a resource'
  end

  describe '#map_subresources' do
    let(:object) { fake('Association') }
    before { mapper_class.config = mapper.config.append_to(:associations, object) }
    it_should_behave_like 'something that can be added to a resource'
  end

  describe "#map_forms" do
    let(:object) { fake('Form') }
    before { mapper_class.config = mapper.config.append_to(:forms, object) }
    it_should_behave_like "something that can be added to a resource"
  end

  describe '#mapper_stack' do
    let(:yaks_context) { super().merge(mapper_stack: [:foo]) }

    it 'should delegate to context' do
      expect(mapper.mapper_stack).to eql [:foo]
    end
  end

  describe "#expand_value" do
    it "should immediately return plain values" do
      expect(mapper.expand_value(:foo)).to equal :foo
    end

    it "should resolve lambdas in the context of the mapper" do
      expect(mapper.expand_value(->{ self })).to be_a Yaks::Mapper
    end
  end

  describe '#expand_uri' do
    let(:template) { '/foo/bar/{x}/{y}' }
    let(:expand)   { true }

    subject(:expanded) { mapper.expand_uri(template, expand) }

    before do
      mapper.call( Struct.new(:x, :y) { def foo ; '/foo/foo' ; end }.new(6, 7) )
    end

    context 'with expansion turned off' do
      let(:expand) { false }

      it 'should keep the template in the response' do
        expect(expanded).to eq '/foo/bar/{x}/{y}'
      end
    end

    context 'with a URI without expansion variables' do
      let(:template) { '/orders' }

      it 'should return the link as is' do
        expect(expanded).to eq '/orders'
      end
    end

    context 'with partial expansion' do
      let(:expand) { [:y] }

      it 'should only expand the given variables' do
        expect(expanded).to eql '/foo/bar/{x}/7'
      end
    end

    context 'with a symbol for a template' do
      let(:template) { -> { object.foo } }

      it 'should use the lookup mechanism for finding the link' do
        expect(expanded).to eq '/foo/foo'
      end
    end

    context "with a nil uri" do
      let(:template) { nil }

      it "should return nil" do
        expect(expanded).to be_nil
      end
    end
  end

end
