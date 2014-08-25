module Yaks
  module FP
    extend self

    # @param [Symbol, String] name
    # @return [Proc]
    def curry_method(name)
      method(name).to_proc.curry
    end


    # @return [Proc]
    def identity_function
      ->(x) {x}
    end
    I = identity_function

    # @param [Symbol] symbol
    # @param [Array] args
    # @param [Proc] blk
    # @return [Proc]
    def send_with_args(symbol, *args, &blk)
      ->(obj) { obj.method(symbol).(*args, &blk) }
    end
  end
end
