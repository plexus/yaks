require 'rails'
require 'yaks-html'

module Rails
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

    module ControllerAdditions
      def yaks(object, opts = {})
        runner = Yaks.global_config.runner(object, { env: env }.merge(opts))
        puts runner.media_type
        render body: runner.call, content_type: runner.media_type
      end

      def self.included(base)
        base.extend ClassMethods
        base.helper_method :yaks if base.respond_to? :helper_method
      end
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Rails::Yaks::ControllerAdditions
  end
end
