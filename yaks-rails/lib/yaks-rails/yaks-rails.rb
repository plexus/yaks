require 'rails'
require 'yaks-rails/controller_additions'
require 'yaks'

module Rails
  module Yaks
    class << self
      attr_accessor :yaks_config
    end

    def configure_yaks(&block)
      Yaks.yaks_config = ::Yaks.new(&block)

      configure do
        ::Yaks::Format.all.each do |format|
          mime_type format.format_name, format.media_type
        end
      end
    end
  end
end
