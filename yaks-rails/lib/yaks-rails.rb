require 'rails'
require 'yaks'

module Rails
  module Yaks
    def self.global_config
      @global_config ||= ::Yaks.new
    end

    def self.global_config=(config)
      @global_config = config
    end

    def self.configure(&block)
      @global_config = ::Yaks.new(&block)
    end

    module ControllerAdditions
      module ClassMethods
        def yaks(object, opts = {})
          runner = Yaks.global_config.runner(object, {env: env}.merge(opts))
          runner.call
        end
      end

      def yaks(object, opts = {})
        runner = Yaks.global_config.runner(object, {env: env}.merge(opts))
        runner.call
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
