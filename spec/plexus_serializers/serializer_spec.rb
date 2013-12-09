require 'spec_helper'

class Pet
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :species, String
end

class PetPeeve
  include Virtus.model

  attribute :id, Integer
  attribute :type, String
end

class Friend
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :pets, Array[Pet]
  attribute :pet_peeve, PetPeeve
end

class FriendSerializer < PlexusSerializers::Serializer
  attributes :id, :name

  has_many :pets
  has_one :pet_peeve
end

class PetSerializer < PlexusSerializers::Serializer
  attributes :id, :name, :species
end

class PetPeeveSerializer < PlexusSerializers::Serializer
  attributes :id, :type
end

describe PlexusSerializers::Serializer do
  let(:john)       { Friend.new(id: 1, name: 'john', pets: [boingboing, wassup], pet_peeve: regexps) }
  let(:boingboing) { Pet.new(id: 2, name: 'boingboing', species: 'dog')                              }
  let(:wassup)     { Pet.new(id: 3, name: 'wassup', species: 'cat')                                  }
  let(:regexps)    { PetPeeve.new(id: 4, type: 'parsing with regexps')                               }

  let(:collection) { FriendSerializer.new.serialize_collection [john] }

  it do
    expect(PlexusSerializers::JsonApiFolder.new(collection).fold).to eq({})
  end

end
