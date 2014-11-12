module Yaks
  module Identifier
    module LinkRelation
      def self.iana_registry
        @iana_registry ||= CSV.read(Yaks::Root.join('resources/iana-link-relations.csv'))
      end

      def self.registered_names
        @registered_names = iana_registry.drop(1).map(&:first)
      end

      def self.iana?(name)
        registered_names.include?(name.to_s)
      end
    end
  end
end
