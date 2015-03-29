module Yaks
  # A "Configurable" class is one that keeps a configuration in a
  # separate immutable object, of type class::Config. say you have
  #
  #     class MyMapper < Yaks::Mapper
  #       # use yaks configuration DSL in here
  #     end
  #
  # The links, associations, etc, that you set up for MyMapper, will
  # be available in MyMapper.config, which is an instance of
  # Yaks::Mapper::Config.
  #
  # Each configuration step, like `link`, `has_many`, will replace
  # MyMapper.config with an updated version, discarding the old
  # config.
  #
  # By extending Configurable, a number of "macros" become available
  # to describe the DSL that subclasses can use. See the docs for
  # `def_set`. `def_forward`, and `def_add`.
  module Configurable
    attr_accessor :config

    def self.extended(child)
      child.config = child::Config.new
    end

    def inherited(child)
      child.config = config
    end

    # Create a DSL method to set a certain config property. The
    # generated method will take either a plain value, or a block,
    # which will be captured and stored instead.
    def def_set(*method_names)
      method_names.each do |method_name|
        define_singleton_method method_name do |arg = Undefined, &block|
          if arg.equal?(Undefined)
            unless block
              raise ArgumentError, "setting #{method_name}: no value and no block given"
            end
            self.config = config.update(method_name => block)
          else
            if block
              raise ArgumentError, "ambiguous invocation setting #{method_name}: give either a value or a block, not both."
            end
            self.config = config.update(method_name => arg)
          end
        end
      end
    end

    # Forward a method to the config object. This assumes the method
    # will return an updated config instance.
    #
    # Either takes a list of methods to forward, or a mapping (hash)
    # of source to destination method name.
    def def_forward(mappings, *args)
      if mappings.instance_of? Hash
        mappings.each do |method_name, target|
          define_singleton_method method_name do |*args, &block|
            self.config = config.public_send(target, *args, &block)
          end
        end
      else
        def_forward([mappings, *args].map{|name| {name => name}}.inject(:merge))
      end
    end

    # Generate a DSL method that creates a certain type of domain
    # object, and adds it to a list on the config.
    #
    #     def_add :fieldset, create: Fieldset, append_to: :fields
    #
    # This will generate a `fieldset` method, which will call
    # `Fieldset.create`, and append the result to `config.fields`
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
