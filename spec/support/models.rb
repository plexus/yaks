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
