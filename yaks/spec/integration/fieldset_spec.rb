RSpec.describe 'dynamic form fields' do
  let(:mapper) do
    Class.new(Yaks::Mapper) do
      type :awesome
      form :foo do
        fieldset do
          legend "I am legend"
          text :bar
        end
      end
    end
  end

  let(:yaks) { Yaks.new }

  it 'should create fieldsets with fields' do
    expect(yaks.map(:foo, mapper: mapper)).to eql Yaks::Resource.new(
      type: :awesome,
      forms: [
        Yaks::Resource::Form.new(
          name: :foo,
          fields: [
            Yaks::Resource::Form::Fieldset.new(
              fields: [
                Yaks::Resource::Form::Legend.new(label: "I am legend", type: :legend),
                Yaks::Resource::Form::Field.new(name: :bar, type: :text)
              ]
            )
          ]
        )
      ]
    )
  end

  it 'should convert to halo' do
    expect(
      yaks.with(default_format: :halo, hooks: [[:skip, :serialize]]).call(:foo, mapper: mapper)
    ).to eql(
      "_controls" => {
        "foo" => {
          "name" =>"foo",
          "fields" => [
            {
              "type" => "fieldset",
              "fields" => [
                {
                  "label" => "I am legend",
                  "type" => "legend"
                }, {
                  "name" => "bar",
                  "type" => "text"
                }
              ]
            }
          ]
        }
      }
    )
  end
end
