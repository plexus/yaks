module Yaks
  class DSLBuilder < BasicObject
    def create(*args, &block)
      @state = @klass.create(*args)
      instance_eval(&block)
      @state
    end

    # Fix a bug with Rubinius where the instance_eval above triggers
    # kind_of?, which ends up in method_missing and messes up the
    # state.
    #
    # Better fix would be to get rid of method_missing and use
    # explicit whitelist of DSL methods.
    def kind_of?(klass)
      klass == DSLBuilder
    end

    def initialize(klass)
      @klass = klass
    end

    def method_missing(method_name, *args, &block)
      @state = @state.public_send(method_name, *args, &block)
      unless @state.is_a?(@klass)
        ::Kernel.raise ::Yaks::IllegalState, "#{@klass}##{method_name}(#{args.map(&:inspect).join(', ')}) returned #{@state.inspect}. Expected instance of #{@klass}"
      end
    end
  end
end
