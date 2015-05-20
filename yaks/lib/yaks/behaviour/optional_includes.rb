require "rack/utils"

module Yaks
  module Behaviour
    module OptionalIncludes
      RACK_KEY = "yaks.optional_includes".freeze

      def associations
        super.select do |association|
          association.if != Undefined || include_association?(association)
        end
      end

      private

      def include_association?(association)
        includes = env.fetch(RACK_KEY) do
          query_string = env.fetch("QUERY_STRING", nil)
          query = Rack::Utils.parse_query(query_string)
          env[RACK_KEY] = query.fetch("include", "").split(",").map { |r| r.split(".") }
        end

        includes.any? do |relationship|
          relationship[mapper_stack.size].eql?(association.name.to_s)
        end
      end
    end
  end
end
