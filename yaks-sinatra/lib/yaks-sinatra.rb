require 'sinatra/base'
require 'yaks'

module Sinatra
  module Yaks
    class << self
      attr_accessor :yaks_config
    end

    def configure_yaks(&block)
      Yaks.yaks_config = ::Yaks.new(&block)

      configure do
        ::Yaks::Format.all.each do |format|
          mime_type format.format_name, format.mime_type
        end
      end
    end
  end

  module YaksHelpers
    def yaks(object, opts = {})
      runner = Yaks.yaks_config.runner(object, {env: env}.merge(opts))
      content_type runner.format_name
      runner.result
    end
  end

  register Yaks
  helpers YaksHelpers
end
