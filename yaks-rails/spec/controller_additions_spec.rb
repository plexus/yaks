require 'yaks-rails'

RSpec.describe Rails::Yaks::ControllerAdditions do

  before(:each) do
    @controller_class = Class.new
    @controller = @controller_class.new

    @controller = double(params: {})
    @controller.send(:include,Rails::Yaks::ControllerAdditions)
  end

  describe '#yaks' do

    it 'renders something' do
      hello = { id: 1, name: 'hahahaha' }

      expect{ puts @controller.yaks(hello) }.not_to raise_error
    end
  end

end

# Yaks::Format.all.each do |format|
#   mime_type format.format_name, format.media_type
# end
#
# # one time Yaks configuration
# yaks = Yaks.new {...}
#
# # on each request
# runner = yaks.runner(object, env: rack_env)
# format = runner.format_name
# output = runner.call