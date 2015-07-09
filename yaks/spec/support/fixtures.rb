RSpec.shared_context 'fixtures' do
  let(:john)       { Friend.new(id: 1, name: 'john', pets: [boingboing, wassup], pet_peeve: regexps) }
  let(:boingboing) { Pet.new(id: 2, name: 'boingboing', species: 'dog')                              }
  let(:wassup)     { Pet.new(id: 3, name: 'wassup', species: 'cat')                                  }
  let(:regexps)    { PetPeeve.new(id: 4, type: 'parsing with regexps')                               }
end
