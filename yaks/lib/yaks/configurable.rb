module Yaks
  module Configurable
    def config_method(name, options)
      define_method name do |*args, &block|
        defaults = options.fetch(:defaults, {})
        klass    = options.fetch(:create)

        instance = if args.length == 1 && args.first.instance_of?(klass)
                     args.first
                   else
                     if args.last.is_a? Hash
                       args[-1] = defaults.merge(args[-1])
                     else
                       args << defaults
                     end
                     klass.create(*args, &block)
                   end

        append_to(options.fetch(:append_to), instance)
      end
    end
  end
end
