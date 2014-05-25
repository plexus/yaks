module Yaks
  module FP
    extend self

    def curry_method(name)
      method(name).to_proc.curry
    end

    def identity_function
      ->(x) {x}
    end
    I = identity_function

    def send_with_args(symbol, *args, &blk)
      ->(obj) { obj.method(symbol).(*args, &blk) }
    end
  end
end
