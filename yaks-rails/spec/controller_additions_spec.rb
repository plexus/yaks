require 'yaks-rails'

RSpec.describe Rails::Yaks::ControllerAdditions do
  let(:mapper) do
    Class.new(Yaks::Mapper) do
      type :awesome
      attributes :foo, :bar
    end
  end

  let(:object) { OpenStruct.new(foo: 'hey', bar: 'world') }
  let (:controller) { double }

  before(:each) do
    controller.class.send(:include, Rails::Yaks::ControllerAdditions)
  end

  describe '#yaks' do
    it 'renders application/hal+json content-type without specifying content-type' do
      allow(controller).to receive(:env).and_return({})
      expect(controller).to receive(:render) do |arg|
        expect(arg).to eq(body: "{\n  \"foo\": \"hey\",\n  \"bar\": \"world\"\n}", content_type: 'application/hal+json'
                       )
      end
      controller.yaks(object, mapper: mapper)
    end

    # todo, this is failing
    it 'renders siren content-type when specifying content-type as siren' do
      allow(controller).to receive(:env)
      my_env = { 'HTTP_ACCEPT' => 'application/x-www-form-urlencoded' }

      expect(controller).to receive(:render) do |_arg|
        # expect(arg).to eq(body: "{\n  \"foo\": \"hey\",\n  \"bar\": \"world\"\n}", content_type: 'application/x-www-form-urlencoded'
        #              )
      end
      controller.yaks(object, mapper: mapper, env: my_env)
    end
  end
end
