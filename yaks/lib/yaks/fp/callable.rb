module Yaks
  module FP
    module Callable
      def to_proc
        method(:call).to_proc
      end
    end
  end
end
