module Yaks
  # State monad-ish thing.
  #
  # Generate a DSL syntax for immutable classes.
  #
  # @example
  #
  #   # This code
  #   Form.create(:search)
  #          .method("POST")
  #          .action("/search")
  #
  #   # Can be written as
  #   StatefulBuilder.new(Form, [:method, :action]).create(:search) do
  #     method "POST"
  #     action "/search"
  #   end
  #
  class StatefulBuilder
    include Configurable

    def create(*args, &block)
      build(@klass.create(*args), &block)
    end

    def build(init_state, &block)
      @config = init_state
      instance_eval(&block) if block
      @config
    end

    def initialize(klass, methods = [], &block)
      @klass = klass
      @methods = methods
      def_forward *methods if methods.any?
      instance_eval(&block) if block
    end

    def inspect
      "#<StatefulBuilder #{@klass} #{@methods.inspect}>"
    end

  end
end
