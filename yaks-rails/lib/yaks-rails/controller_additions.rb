module Rails
  module ControllerAdditions
    module ClassMethods
      def yaks(object, opts = {})
        runner = Yaks.yaks_config.runner(object, { env: env }.merge(opts))
        content_type runner.format_name
        runner.call
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.helper_method :yaks if base.respond_to? :helper_method
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Rails::Yaks::ControllerAdditions
  end
end
