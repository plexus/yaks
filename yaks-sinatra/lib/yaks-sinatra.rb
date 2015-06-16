require 'sinatra/base'
require 'yaks'

module Yaks
  module Sinatra
    class << self
      attr_accessor :yaks_config
    end

    module Helpers
      def yaks(object, opts = {})
        runner = Yaks::Sinatra.yaks_config.runner(object, {env: env}.merge(opts))
        content_type runner.format_name
        runner.call
      end
    end

    def configure_yaks(&block)
      Yaks::Sinatra.yaks_config = ::Yaks.new(&block)

      configure do
        ::Yaks::Format.all.each do |format|
          mime_type format.format_name, format.media_type
        end
      end
    end

    def self.registered(app)
      app.helpers(Yaks::Sinatra::Helpers)

      ::Yaks::Format.all.each do |format|
        app.settings.add_charset << format.media_type
      end

      # app.configure_yaks
    end
  end
end

# For classic apps
module Sinatra
  register Yaks::Sinatra
end
