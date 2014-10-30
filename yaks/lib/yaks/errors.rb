module Yaks
  Error = Class.new(StandardError)

  IllegalStateError         = Class.new(Error)
  UnsupportedOperationError = Class.new(Error)
  PrimitivizeError          = Class.new(Error)
end
