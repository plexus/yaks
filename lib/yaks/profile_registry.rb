# -*- coding: utf-8 -*-
module Yaks
  # RFC6906 The "profile" link relation http://tools.ietf.org/search/rfc6906
  class ProfileRegistry
    class << self
      include Util

      def create(&blk)
        blk ||= ->{}
        Class.new(self).tap(&σ(:instance_eval, &blk)).new
      end

      def profile(type, uri)
        profiles {|reg| reg.put(type, uri)}
      end

      def profiles
        @profiles ||= Yaks::Hash()
        @profiles = yield(@profiles) if block_given?
        @profiles
      end

      def inherited(child)
        child.profiles { @profiles }
      end
    end

    def find_by_type(type)
      self.class.profiles[type]
    end

    def find_by_uri(by_uri)
      self.class.profiles.detect {|type, uri| uri == by_uri}.first
    end
  end

  class NullProfileRegistry
    def find_by_type(type)
      type.to_s
    end

    def find_by_uri(uri)
      uri.to_sym
    end
  end
end
