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
  #   Builder.new(Form, [:method, :action]).create(:search) do
  #     method "POST"
  #     action "/search"
  #   end
  #
  class Builder
    include Configurable

    def create(*args, &block)
      build(@klass.create(*args), &block)
    end

    def build(init_state, *extra_args, &block)
      @config = init_state
      instance_exec(*extra_args, &block) if block
      @config
    end

    def initialize(klass, methods = [], &block)
      @klass = klass
      @methods = methods
      def_forward *methods if methods.any?
      instance_eval(&block) if block
    end

    def inspect
      "#<Builder #{@klass} #{@methods.inspect}>"
    end

  end
end
