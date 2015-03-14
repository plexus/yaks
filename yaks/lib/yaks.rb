require 'forwardable'
require 'set'
require 'pathname'
require 'json'
require 'csv'

require 'anima'
require 'concord'
require 'inflection'
require 'uri_template'
require 'rack/accept'

require 'yaks/version'
require 'yaks/util'
require 'yaks/configurable'
require 'yaks/fp'
require 'yaks/fp/callable'
require 'yaks/primitivize'
require 'yaks/attributes'
require 'yaks/builder'
require 'yaks/errors'

require 'yaks/default_policy'
require 'yaks/serializer'
require 'yaks/config'


module Yaks
  Undefined = Module.new.freeze

  # Set the Root constant as the gems root path
  Root = Pathname(__FILE__).join('../..')

  DSL_METHODS = [
    :format_options,
    :rel_template,
    :before,
    :after,
    :around,
    :skip,
    :namespace,
    :mapper_namespace,
    :serializer,
    :json_serializer,
    :map_to_primitive,
  ]

  ConfigBuilder = Builder.new(Yaks::Config) do
    def_set *Yaks::Config.attributes.names
    def_forward *DSL_METHODS
    def_forward *Yaks::DefaultPolicy.public_instance_methods(false)
  end

  class << self
    # @param [Proc] blk
    # @return [Yaks::Config]

    def new(&blk)
      ConfigBuilder.create(&blk)
    end
  end
end


require 'yaks/resource'
require 'yaks/null_resource'
require 'yaks/resource/link'
require 'yaks/collection_resource'

require 'yaks/html5_forms'
require 'yaks/identifier/link_relation'

require 'yaks/mapper/association'
require 'yaks/mapper/has_one'
require 'yaks/mapper/has_many'
require 'yaks/mapper/attribute'
require 'yaks/mapper/link'
require 'yaks/mapper/form/config'
require 'yaks/mapper/form/field/option'
require 'yaks/mapper/form/field'
require 'yaks/mapper/form/fieldset'
require 'yaks/mapper/form'
require 'yaks/mapper/config'
require 'yaks/mapper'
require 'yaks/mapper/association_mapper'
require 'yaks/collection_mapper'

require 'yaks/resource/has_fields'
require 'yaks/resource/form'
require 'yaks/resource/form/field'
require 'yaks/resource/form/field/option'
require 'yaks/resource/form/fieldset'

require 'yaks/format'
require 'yaks/format/hal'
require 'yaks/format/halo'
require 'yaks/format/json_api'
require 'yaks/format/collection_json'

require 'yaks/reader/hal'
require 'yaks/reader/json_api'
require 'yaks/pipeline'
require 'yaks/runner'
