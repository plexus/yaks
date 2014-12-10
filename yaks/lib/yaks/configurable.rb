module Yaks
  module Configurable
    attr_accessor :config

    def self.extended(child)
      child.config = child::Config.new
    end

    def inherited(child)
      child.config = config
    end

    def def_set(*method_names)
      method_names.each do |method_name|
        define_singleton_method method_name do |arg|
          self.config = config.update(method_name => arg)
        end
      end
    end

    def def_forward(method_names, *args)
      unless method_names.is_a? Hash
        def_forward([method_names, *args].map{|name| {name => name}}.inject(:merge))
        return
      end
      method_names.each do |method_name, target|
        define_singleton_method method_name do |*args, &block|
          self.config = config.public_send(target, *args, &block)
        end
      end
    end

    def def_add(name, options)
      define_singleton_method name do |*args, &block|
        defaults = options.fetch(:defaults, {})
        klass    = options.fetch(:create)

        if args.last.instance_of?(Hash)
          args[-1] = defaults.merge(args[-1])
        else
          args << defaults
        end

        self.config = config.append_to(
          options.fetch(:append_to),
          klass.create(*args, &block)
        )
      end
    end

  end
end
