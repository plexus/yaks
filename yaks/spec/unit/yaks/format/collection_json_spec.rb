RSpec.describe Yaks::Format::CollectionJson do
  context 'with the plant collection resource' do
    include_context 'plant collection resource'

    subject { Yaks::Primitivize.create.call(described_class.new.call(resource)) }

    it { should deep_eql(load_json_fixture('plant_collection.collection')) }
  end

  describe '#links?' do
    context 'when resource is not a collection' do
      let(:resource) {
        Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          links: [Yaks::Resource::Link.new(rel: 'the_rel', uri: 'the_uri')]
        )
      }

      let(:cj) { Yaks::Format::CollectionJson.new(resource) }

      it 'should return false' do
        expect(cj.links?(resource)).to eq false
      end
    end

    context 'when resource is a collection' do
      let(:cj) { Yaks::Format::CollectionJson.new(resource) }

      context 'and has links' do
        let(:resource) {
          Yaks::CollectionResource.new(
            links: [Yaks::Resource::Link.new(rel: 'the_rel', uri: 'the_uri')]
          )
        }

        it 'should return true' do
          expect(cj.links?(resource)).to eq true
        end
      end

      context 'and has no links' do
        let(:resource) {
          Yaks::CollectionResource.new(
            links: []
          )
        }

        it 'should return false' do
          expect(cj.links?(resource)).to eq false
        end
      end
    end
  end

  describe '#queries?' do
    let(:resource) {
      Yaks::Resource.new(
        attributes: {foo: 'fooval', bar: 'barval'},
        forms: [Yaks::Resource::Form.new(full_args)]
      )
    }

    subject {
      Yaks::Primitivize.create.call(described_class.new.call(resource))
    }

    context 'when resource has GET forms' do
      context 'and form has an action' do
        let(:full_args) {
          {
            name: :search,
            method: 'GET',
            action: '/foo'
          }
        }

        it 'should return true' do
          cj = Yaks::Format::CollectionJson.new(resource)
          expect(cj.queries?(resource)).to eq true
        end
      end

      context 'and form has no action' do
        let(:full_args) {
          {
            name: :search,
            method: 'GET'
          }
        }

        it 'should return false' do
          cj = Yaks::Format::CollectionJson.new(resource)
          expect(cj.queries?(resource)).to eq false
        end
      end

      context 'and form has no method' do
        let(:full_args) {
          {
            name: :search,
            action: '/foo'
          }
        }

        it 'should return false' do
          cj = Yaks::Format::CollectionJson.new(resource)
          expect(cj.queries?(resource)).to eq false
        end
      end
    end

    context 'when resource has not GET forms' do
      let(:full_args) {
        {
          name: :search,
          method: 'POST'
        }
      }

      it 'should return false' do
        cj = Yaks::Format::CollectionJson.new(resource)
        expect(cj.queries?(resource)).to eq false
      end
    end
  end

  describe '#template?' do
    context 'when no template form has been specified' do
      let(:format) {
        described_class.new
      }

      let(:resource) {
        Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          forms: [Yaks::Resource::Form.new(name: :just_a_form)]
        )
      }

      it 'should return false' do
        expect(format.template?(resource)).to eq false
      end
    end

    context 'when a template form has been specified' do
      let(:format) {
        described_class.new(:template => :template_form_name)
      }

      context 'and the form is not present' do
        let(:resource) {
          Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          forms: [Yaks::Resource::Form.new(name: :not_the_form_name)]
          )
        }

        subject {
          Yaks::Primitivize.create.call(format.call(resource))
        }

        it 'should return false' do
          expect(format.template?(resource)).to eq false
        end
      end

      context 'and the form is present' do
        let(:resource) {
          Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          forms: [Yaks::Resource::Form.new(name: :template_form_name)]
          )
        }

        subject {
          Yaks::Primitivize.create.call(format.call(resource))
        }

        it 'should return true' do
          expect(format.template?(resource)).to eq true
        end
      end
    end
  end

  describe '#serialize_links' do
    context 'without title' do
      let(:resource) {
        Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          links: [Yaks::Resource::Link.new(rel: 'the_rel', uri: 'the_uri')]
        )
      }

      subject {
        Yaks::Primitivize.create.call(described_class.new.call(resource))
      }

      it 'should not render a name' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ],
                "links" => [{"rel"=>"the_rel", "href"=>"the_uri"}]
              }
            ]
          }
        )
      end
    end

    context 'with a title' do
      let(:resource) {
        Yaks::Resource.new(
          attributes: {foo: 'fooval', bar: 'barval'},
          links: [Yaks::Resource::Link.new(options: {title: 'the_name'}, rel: 'the_rel', uri: 'the_uri')]
        )
      }

      subject {
        Yaks::Primitivize.create.call(described_class.new.call(resource))
      }

      it 'should render a name' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ],
                "links" => [{"name"=>"the_name", "rel"=>"the_rel", "href"=>"the_uri"}]
              }
            ]
          }
        )
      end
    end
  end

  describe '#serialize_queries' do
    let(:resource) {
      Yaks::Resource.new(
        attributes: {foo: 'fooval', bar: 'barval'},
        forms: [
          Yaks::Resource::Form.new(full_args),
          Yaks::Resource::Form.new(name: :no_render, action: '/foo', method: 'POST')
        ]
      )
    }

    subject {
      Yaks::Primitivize.create.call(described_class.new.call(resource))
    }

    context 'when form method is GET' do
      context "form uses only required fields" do
        let(:full_args) {
          {
            name: :search,
            action: '/foo',
            method: 'GET'
          }
        }

        it 'should render the queries array' do
          should deep_eql(
            "collection" => {
              "version" => "1.0",
              "items" => [
                {
                  "data" => [
                    { "name"=>"foo", "value"=>"fooval" },
                    { "name"=>"bar", "value"=>"barval" }
                  ]
                }
              ],
              "queries" => [
                { "href"=>"/foo", "rel"=>"search" }
              ]
            }
          )
        end
      end

      context "form uses optional fields" do
        let(:fields) {
          [
            Yaks::Resource::Form::Field.new(name: 'foo'),
            Yaks::Resource::Form::Field.new(name: 'bar', label: 'My Bar Field')
          ]
        }

        let(:full_args) {
          {
            name: :search,
            action: '/foo',
            method: 'GET',
            title: 'My query prompt',
            fields: fields
          }
        }

        it 'should render the queries array with optional fields' do
          should deep_eql(
            "collection" => {
              "version" => "1.0",
              "items" => [
                {
                  "data" => [
                    { "name"=>"foo", "value"=>"fooval" },
                    { "name"=>"bar", "value"=>"barval" }
                  ]
                }
              ],
              "queries" => [
                { "href"=>"/foo", "rel"=>"search", "prompt"=>"My query prompt",
                  "data"=>
                  [
                    { "name"=>"foo", "value"=>"" },
                    { "name"=>"bar", "value"=>"", "prompt"=>"My Bar Field" }
                  ]
                }
              ]
            }
          )
        end
      end
    end
  end

  describe '#serialize_template' do
    let(:format) {
      described_class.new(:template => :form_for_new)
    }

    let(:resource) {
      Yaks::Resource.new(
        attributes: {foo: 'fooval', bar: 'barval'},
        forms: [Yaks::Resource::Form.new(name: :form_for_new, fields: fields)]
      )
    }

    subject {
      Yaks::Primitivize.create.call(format.call(resource))
    }

    context "template uses prompts" do
      let(:fields) {
        [
          Yaks::Resource::Form::Field.new(name: 'foo', label: 'My Foo Field'),
          Yaks::Resource::Form::Field.new(name: 'bar', label: 'My Bar Field')
        ]
      }

      it 'should render a template' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ]
              }
            ],
            "template" => {
              "data" => [
                { "name"=>"foo", "value"=>"", "prompt"=>"My Foo Field" },
                { "name"=>"bar", "value"=>"", "prompt"=>"My Bar Field" }
              ]
            }
          }
        )
      end
    end

    context "template does not use prompts" do
      let(:fields) {
        [
          Yaks::Resource::Form::Field.new(name: 'foo'),
          Yaks::Resource::Form::Field.new(name: 'bar')
        ]
      }

      it 'should render a template without prompts' do
        should deep_eql(
          "collection" => {
            "version" => "1.0",
            "items" => [
              {
                "data" => [
                  { "name"=>"foo", "value"=>"fooval" },
                  { "name"=>"bar", "value"=>"barval" }
                ]
              }
            ],
            "template" => {
              "data" => [
                { "name"=>"foo", "value"=>"" },
                { "name"=>"bar", "value"=>"" }
              ]
            }
          }
        )
      end
    end
  end
end
