module Yaks
  module Util
    extend self
    extend Forwardable

    def_delegators Inflection, :singular, :singularize, :pluralize

    def underscore(str)
      str.gsub(/::/, '/')
         .gsub(/(?<!^)([A-Z])(?=[a-z$])|(?<=[a-z])([A-Z])/, '_\1\2')
         .tr("-", "_")
         .downcase!
    end

    def camelize(str)
      str.gsub(/\/(.?)/)      { "::#{ $1.upcase }" }
         .gsub!(/(?:^|_)(.)/) { $1.upcase          }
    end

  end
end
