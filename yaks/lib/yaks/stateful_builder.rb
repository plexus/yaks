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
  #          .href("/search")
  #
  #   # Can be written as
  #   StatefulBuilder.new(Control, [:method, :href]).create(:search) do
  #     method "POST"
  #     href "/search"
  #   end
  #
  class StatefulBuilder < BasicObject
    def create(*args, &block)
      @state = @klass.create(*args)
      instance_eval(&block)
      @state
    end

    def initialize(klass, methods)
      @klass = klass
      StatefulMethods.new(methods).send(:extend_object, self)
    end

    def validate_state(method_name, args)
      unless @state.instance_of?(@klass)
        ::Kernel.raise(
          IllegalState,
          "#{@klass}##{method_name}(#{args.map(&:inspect).join(', ')}) "\
          "returned #{@state.inspect}. Expected instance of #{@klass}"
        )
      end
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
