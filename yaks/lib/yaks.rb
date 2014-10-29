# -*- coding: utf-8 -*-

require 'forwardable'
require 'set'
require 'pathname'
require 'json'

require 'anima'
require 'concord'
require 'inflection'
require 'uri_template'
require 'rack/accept'

require 'yaks/util'
require 'yaks/configurable'
require 'yaks/fp'
require 'yaks/fp/callable'
require 'yaks/primitivize'
require 'yaks/attributes'
require 'yaks/dsl_builder'

require 'yaks/default_policy'

module Yaks
  # A PORO
  Undefined = Object.new
  # Set the Root constant as the gems root path
  Root = Pathname(__FILE__).join('../..')

  class << self
    # @param [Proc] blk
    # @return [Yaks::Config]
    def new(&blk)
      Yaks::Config.new(&blk)
    end
  end

end


require 'yaks/resource'
require 'yaks/null_resource'
require 'yaks/resource/link'
require 'yaks/collection_resource'

require 'yaks/mapper/association'
require 'yaks/mapper/has_one'
require 'yaks/mapper/has_many'
require 'yaks/mapper/attribute'
require 'yaks/mapper/link'
require 'yaks/mapper/control'
require 'yaks/mapper/config'
require 'yaks/mapper/class_methods'
require 'yaks/mapper'
require 'yaks/mapper/association_mapper'
require 'yaks/collection_mapper'

require 'yaks/resource/control'

require 'yaks/serializer'

require 'yaks/format'
require 'yaks/format/hal'
require 'yaks/format/json_api'
require 'yaks/format/collection_json'

require 'yaks/config/dsl'
require 'yaks/config'
require 'yaks/runner'
