module Youtypeitwepostit
  class Message
    include Virtus.model

    attribute :id, Integer
    attribute :text, String
    attribute :date_posted, String
  end

  class MessageMapper < Yaks::Mapper
    link :self, 'http://www.youtypeitwepostit.com/api/{id}'
    link :profile, 'http://www.youtypeitwepostit.com/profiles/message'

    attributes :text, :date_posted
  end

  class CollectionMapper < Yaks::CollectionMapper
    link :self, 'http://www.youtypeitwepostit.com/api/'
  end
end
