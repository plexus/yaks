module Yaks
  class Format
    class Siren < self
      register :siren, :json, 'application/vnd.siren+json'

      def transitive?
        true
      end

      def inverse
        Yaks::Reader::Siren.new
      end

      protected

      # @param [Yaks::Resource] resource
      # @return [Hash]
      def serialize_resource(resource)
      end
    end
  end
end
