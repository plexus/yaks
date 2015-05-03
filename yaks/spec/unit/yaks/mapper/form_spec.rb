RSpec.describe Yaks::Mapper::Form do
  include_context 'yaks context'

  let(:form) { described_class.create(*full_args, &block_arg) }
  let(:name) { :the_name }
  let(:full_args) { [{name: name}.merge(args)] }
  let(:block_arg) { nil }
  let(:args) {
    {
      action: '/foo',
      title: 'a title',
      method: 'PATCH',
      media_type: 'application/hal+json',
      fields: fields
    }
  }
  let(:fields) { [] }
  let(:mapper) { Yaks::Mapper.new(yaks_context) }

  describe ".create" do
    it "should have a name of nil when ommitted" do
      expect(described_class.create.name).to be_nil
    end

    context "with a symbol arg" do
      let(:full_args) { [:the_name] }
      it "should use the symbol as the form's name" do
        expect(form.name).to be :the_name
      end
    end

    context "with a name given in the options hash" do
      it "should use that name" do
        expect(form.name).to be :the_name
      end
    end

    context "with a block" do
      let(:block_arg) { ->{ method 'POST' } }

      it "should use it as configuration block" do
        expect(form.method).to eql 'POST'
      end
    end
  end

  describe '#add_to_resource' do
    let(:resource) { form.new.add_to_resource(Yaks::Resource.new, mapper, nil) }

    context 'with fields' do
      let(:fields) {
        [
          Yaks::Mapper::Form::Field.new(
            name: 'field name',
            label: 'field label',
            type: 'text',
            value: 7
          )
        ]
      }
    end

    it "should add the form to the resource" do
      expect(form.add_to_resource(Yaks::Resource.new, mapper, nil))
        .to eql Yaks::Resource.new(
          forms: [
            Yaks::Resource::Form.new(
              name: :the_name,
              action: "/foo",
              title: "a title",
              method: "PATCH",
              media_type: "application/hal+json",
              fields: []
            )
          ]
        )
    end

    context 'with a truthy condition' do
      let(:form) { described_class.create { condition { true }}}

      it 'should add the form' do
        expect(form.add_to_resource(Yaks::Resource.new, mapper, nil).forms.length).to be 1
      end
    end

    context 'with a falsey condition' do
      let(:form) { described_class.create { condition { false }}}

      it 'should not add the form' do
        expect(form.add_to_resource(Yaks::Resource.new, mapper, nil).forms.length).to be 0
      end
    end
  end

  describe '#to_resource_form' do
    let(:block_arg) do
      -> do
        method { 'POST' }
        action { '/foo/bar' }

        text :name, required: true
      end
    end

    it "should create a matching Yaks::Resource::Form" do
      expect(form.to_resource_form(mapper))
        .to eql Yaks::Resource::Form.new(
          name: :the_name,
          action: "/foo/bar",
          title: "a title",
          method: "POST",
          media_type: "application/hal+json",
          fields: [
            Yaks::Resource::Form::Field.new(name: :name, type: :text, required: true)
          ]
        )
    end

    context 'with dynamic elements' do
      let(:args) {{}}
      let(:block_arg) do
        -> do
          dynamic do |object|
            text object.name
          end
        end
      end

      it 'should render them based on the mapped object' do
        mapper.call(fake(name: :anthony)) # hack to set the mapper's object
        expect(form.to_resource_form(mapper)).to eql(
          Yaks::Resource::Form.new(
            name: :the_name,
            fields: [
              Yaks::Resource::Form::Field.new(name: :anthony, type: :text)
            ]
          )
        )
      end
    end
  end
end
