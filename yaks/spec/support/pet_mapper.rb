class PetMapper < Yaks::Mapper
  attributes :id, :name, :species
end
class GreatPetMapper < Yaks::Mapper; end
class GreatPetCollectionMapper < Yaks::Mapper; end
