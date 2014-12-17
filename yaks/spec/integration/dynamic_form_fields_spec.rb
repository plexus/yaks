RSpec.describe 'dynamic form fields' do
  let(:mapper) do
    Class.new(Yaks::Mapper) do
      type :awesome
      form :foo do
        text :name
        dynamic do |object|
          object.each do |x|
            text x
          end
        end
      end
    end
  end

  let(:yaks) { Yaks.new }
  let(:object) { [:a, :b, :c] }

  it 'should create dynamic form fields' do

    expect(yaks.map(object, mapper: mapper)).to eql Yaks::Resource.new(
      type: :awesome,
      forms: [
        Yaks::Resource::Form.new(
          name: :foo,
          fields: [
            Yaks::Resource::Form::Field.new(name: :name, type: :text),
            Yaks::Resource::Form::Field.new(name: :a, type: :text),
            Yaks::Resource::Form::Field.new(name: :b, type: :text),
            Yaks::Resource::Form::Field.new(name: :c, type: :text)
          ]
        )
      ]
    )
  end
end
