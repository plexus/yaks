require 'rails'
require 'yaks-html'


module Yaks
  def self.global_config
    @global_config ||= ::Yaks.new
  end

  class << self
    attr_writer :global_config
  end

  def self.configure(&block)
    @global_config = ::Yaks.new(&block)
  end

  module Rails
    module ControllerAdditions
      def yaks(object, opts = {})
        runner = Yaks.global_config.runner(object, {env: env}.merge(opts))
        render body: runner.call, content_type: runner.media_type
      end
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Rails::Yaks::ControllerAdditions
  end
end
