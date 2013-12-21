class PetMapper < Yaks::Mapper
  attributes :id, :name, :species

  #link :collection, '/api/pets/{id*}'
end
