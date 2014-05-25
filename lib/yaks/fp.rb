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

    def curry_symbol(symbol, *args, &blk)
      ->(obj) { obj.method(symbol).to_proc.curry.(*args, &blk) }
    end
    alias send_with_args curry_symbol
  end
end
