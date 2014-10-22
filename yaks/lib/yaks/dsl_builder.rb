module Yaks
  class DSLBuilder < BasicObject
    def create(*args, &block)
      @state = @klass.create(*args, &block)
      instance_eval(&block)
      @state
    end

    def initialize(klass)
      @klass = klass
    end

    def method_missing(method_name, *args, &block)
      @state = @state.send(method_name, *args, &block)
    end
  end
end
