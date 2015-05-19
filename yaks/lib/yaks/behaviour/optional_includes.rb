require "rack/utils"

module Yaks
  module Behaviour
    module OptionalIncludes
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def has_one(name, options = {}) # rubocop:disable Style/PredicateName
          super name, options.merge(if: ->{include_association?(name)})
        end

        def has_many(name, options = {}) # rubocop:disable Style/PredicateName
          super name, options.merge(if: ->{include_association?(name)})
        end
      end

      private

      def include_association?(name)
        query = Rack::Utils.parse_query(env["QUERY_STRING"].to_s)
        includes = query["include"].to_s.split(",")
        includes.any? do |relationship|
          relationship.split(".")[mapper_stack.size] == name.to_s
        end
      end
    end
  end
end
