# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    module MapLinks

      def map_links
        mapped = links.map &curry_symbol(:expand_with, method(:load_attribute))
        unless links.any? {|link| link.rel? :profile }
          mapped = mapped.cons(Resource::Link.new(:profile, profile_registry.find_by_type(profile_type), {}))
        end
        mapped
      end

    end
  end
end
