class FriendSerializer < Yaks::Serializer
  attributes :id, :name

  has_many :pets
  has_one :pet_peeve
end

class PetSerializer < Yaks::Serializer
  attributes :id, :name, :species
end

class PetPeeveSerializer < Yaks::Serializer
  attributes :id, :type
end
