module Yaks
  # State monad-ish thing.
  #
  # Generate a DSL syntax for immutable classes.
  #
  # @example
  #
  #   # This code
  #   Control.create(:search)
  #          .method("POST")
  #          .action("/search")
  #
  #   # Can be written as
  #   StatefulBuilder.new(Control, [:method, :action]).create(:search) do
  #     method "POST"
  #     action "/search"
  #   end
  #
  class StatefulBuilder < BasicObject
    def create(*args, &block)
      build(@klass.create(*args), &block)
    end

    def build(init_state, &block)
      @state = init_state
      instance_eval(&block) if block
      @state
    end

    def initialize(klass, methods = nil)
      @klass = klass
      @methods = methods || klass.attributes.names
      StatefulMethods.new(@methods).send(:extend_object, self)
    end

    def validate_state(method_name, args)
      unless @state.instance_of?(@klass)
        ::Kernel.raise(
          IllegalStateError,
          "#{@klass}##{method_name}(#{args.map(&:inspect).join(', ')}) "\
          "returned #{@state.inspect}. Expected instance of #{@klass}"
        )
      end
    end

    def inspect
      "#<StatefulBuilder #{@klass} #{@methods.inspect}>"
    end

    class StatefulMethods < ::Module
      def initialize(methods)
        methods.each { |name| define_stateful_method(name) }
      end

      def define_stateful_method(method_name)
        define_method method_name do |*args, &block|
          @state = @state.public_send(method_name, *args, &block)
          validate_state(method_name, args)
        end
      end
    end
  end
end
