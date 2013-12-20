# -*- coding: utf-8 -*-

module Yaks
  class Mapper
    extend ClassMethods, Forwardable
    include Concord.new(:subject)
    include Util

    def attributes
      self.class.__mapper_config.attributes
    end

    def map_to_resource
      Resource.new(
        Yaks::Hash(
          attributes
            .map &juxt(ι, μ(:load_attribute))))
    end

    def load_attribute(name)
      respond_to?(name) ? send(name) : subject.send(name)
    end

  end
end
