module Yaks
  class DSLBuilder < BasicObject
    def create(*args, &block)
      @state = @klass.create(*args)
      instance_eval(&block)
    end

    def initialize(klass)
      @klass = klass
    end

    def method_missing(method_name, *args, &block)
      @state = @state.public_send(method_name, *args, &block)
    end
  end
end
