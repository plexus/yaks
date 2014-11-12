# -*- coding: utf-8 -*-
module Yaks
  module Util
    extend self
    extend Forwardable

    def_delegators Inflection, :singular, :singularize, :pluralize

    def underscore(str)
      str.gsub(/::/, '/')
        .gsub(/(?<!^|\/)([A-Z])(?=[a-z$])|(?<=[a-z])([A-Z])/, '_\1\2')
        .tr("-", "_")
        .downcase
    end

    def camelize(str)
      str.gsub(/\/(.?)/)     { "::#{ $1.upcase }" }
        .gsub!(/(?:^|_)(.)/) { $1.upcase          }
    end

    def slice_hash(hash, *keys)
      keys.each_with_object({}) {|k,dest| dest[k] = hash[k] if hash.key?(k) }
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) {|(k,v), hsh| p [k,v]; hsh[k.to_sym] = v}
    end

    # Turn what is maybe a Proc into its result (or itself)
    #
    # When input can be either a value or a proc that returns a value,
    # this conversion function can be used to resolve the thing to a
    # value.
    #
    # The proc can be evaluated (instance_evaled) in a certain context,
    # or evaluated as a closure.
    #
    # @param [Object|Proc] maybe_proc
    #   A proc or a plain value
    # @param [Object] context
    #   (optional) A context used to instance_eval the proc
    def Resolve(maybe_proc, context = nil)
      if maybe_proc.is_a? Proc or maybe_proc.is_a? Method
        if context
          if maybe_proc.arity > 0
            context.instance_eval(&maybe_proc)
          else
            # In case it's a lambda with zero arity instance_eval fails
            context.instance_exec(&maybe_proc)
          end
        else
          maybe_proc.()
        end
      else
        maybe_proc
      end
    end

  end
end
